class Account
  attr_reader :rest, :stream, :screen_name
  def initialize(key)
    @rest = Twitter::REST::Client.new key
    @stream = Twitter::Streaming::Client.new key
    @screen_name = @rest.user.screen_name
  end
end

class PluginManager
  @@plugins = {}
  @@readed = []

  class << self
    def add type, plugin
      @@plugins[type] ||= []
      @@plugins[type] << plugin
    end

    def handle obj, account
      case obj
      when Twitter::Tweet
        return if @@readed.include?(obj.id)
        @@readed << obj.id
        @@readed.shift if @@readed.size > 100

        return if obj.retweet?
        return if obj.user.screen_name == "nkroid"

        obj.text =~ /^@\w+?\s+?(.+)/
        if $1
          obj.args = $1.split
        end

        callback :tweet, obj, account
        @@plugins[:command].to_a.each do |command|
          if obj.text =~ /^@(?:nkroid)\s+#{command.arg}/
            command.proc.call obj, account
          end
        end
      when Twitter::Streaming::FriendList
        callback :friend_list, obj, account
      when Twitter::Streaming::Event
        callback :event, obj, account
      when Twitter::Streaming::DeletedTweet
        callback :deleted_tweet, obj, account
      end
    rescue Exception
      console.error $!
    end

    def callback type, obj, account
      @@plugins[type].to_a.each do |plugin|
        plugin.proc.call obj, account
      end
    end
  end
end

class Plugin
  @type = nil

  attr_reader :proc, :opts
  def initialize opts={}, &blk
    @proc = blk
    @opts = opts
  end

  class << self
    def type type
      @type = type
    end

    def hook opts={}, &blk
      PluginManager.add @type, self.new(opts, &blk)
    end
  end
end

class Tweet < Plugin
  type :tweet
end

class Command < Plugin
  type :command
  @@commands = []

  attr_reader :arg
  def initialize cmd, opts={}, &blk
    @proc = blk
    @opts = opts
    @arg = cmd
    @@commands << cmd
  end

  class << self
    def register cmd, opts={}, &blk
      PluginManager.add @type, self.new(cmd, opts, &blk)
    end

    def commands
      @@commands
    end

    def check tweet
      @@commands.each do |cmd|
        return true if tweet.text =~ /^@(?:nkroid)\s+#{cmd}/
      end

      return false
    end
  end
end

class FriendList < Plugin
  type :friend_list
end

class Event < Plugin
  type :event
end

class DeletedTweet < Plugin
  type :deleted_tweet
end

class Init
  @@procs = []

  class << self
    def hook &blk
      @@procs << blk
    end

    def call
      @@procs.each do |blk|
        blk.call
      end
    end
  end
end

class Twitter::Tweet
  attr_accessor :args

  def reply text, rest
    rest.update "@#{self.user.screen_name}\s"+text, in_reply_to_status: self
  end
end

class Twitter::User
  @@locker = {}

  def locker
    @@locker[self.id] ||= nil
  end

  def locker= locker
    @@locker[self.id] = locker
  end

  def locked?
    !!(@@locker[self.id] ||= nil)
  end

  def unlock
    @@locker[self.id] = nil
  end
end
