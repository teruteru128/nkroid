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
        callback :tweet, obj, account
        @@plugins[:command].to_a.each do |command|
          if obj.text =~ /^@(?:nkroid)\s+#{command.arg}/
            command.proc.call obj, account
          end
        end
      when Twitter::Streaming::FriendList
        callback :friend_list, obj, account
        console.info "@#{account.screen_name} Stream connected."
      when Twitter::Streaming::Event
        callback :event, obj, account
      when Twitter::Streaming::DeletedTweet
        callback :deleted_tweet, obj, account
      end
    rescue
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

  attr_reader :arg
  def initialize cmd, opts={}, &blk
    @proc = blk
    @opts = opts
    @arg = cmd
  end

  def self.register cmd, opts={}, &blk
    PluginManager.add @type, self.new(cmd, opts, &blk)
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

class Twitter::Tweet
  def reply text, rest
    rest.update "@#{self.user.screen_name}\s"+text, in_reply_to_status: self
  end
end

def decodeSnowflake id
  Time.at(((id >> 22) + 1288834974657) / 1000.0)
end