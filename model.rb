class Account
  attr_reader :rest, :stream, :screen_name
  attr_accessor :thread
  @accounts = []

  def initialize(key)
    @rest = Twitter::REST::Client.new(key)
    @stream = Twitter::Streaming::Client.new(key)
    @screen_name = @rest.user.screen_name
  end

  def start_stream
    self.stream.user replies: 'all' do |obj|
      begin
        case obj
        when Twitter::Tweet
          Tweet.callback obj, self

          obj.text =~ /^@\w+?\s+?(.+)/
          if $1
            obj.args = $1.split
          end
          Command.all.each do |command|
            if obj.text =~ /^@(?:nkroid)\s+#{command.arg}/
              command.proc.call obj, self
            end
          end
        when Twitter::Streaming::FriendList
          FriendList.callback obj, self
        when Twitter::Streaming::Event
          Event.callback obj, self
        when Twitter::Streaming::DeletedTweet
          DeletedTweet.callback obj, self
        end
      rescue
        console.error $!
        next
      end
    end
  rescue
    console.error $!
    retry
  end

  class << self
    attr_reader :accounts

    def register *args
      @accounts << self.new(*args)
    end

    def all
      Array(@accounts)
    end

    def find screen_name
      @accounts.find{|a|a.screen_name == screen_name}
    end

    def threads
      Account.all.map{|a|a.thread}
    end

    def load_yaml path
      YAML.load_file(path).each do |k,v|
        Account.register(v)
      end
    end
  end
end

class Plugin
  attr_reader :proc, :opts
  def initialize opts={}, &blk
    @proc = blk
    @opts = opts
  end

  class << self
    attr_reader :plugins
    alias :all :plugins

    def hook opts={}, &blk
      @plugins ||= []
      @plugins << self.new(opts, &blk)
    end

    def callback *args
      Array(@plugins).each do |plugin|
        plugin.proc.call *args
      end
    end
  end
end

class Tweet < Plugin
end

class Command < Plugin
  attr_reader :arg
  def initialize cmd, opts={}, &blk
    @proc = blk
    @opts = opts
    @arg = cmd
  end

  class << self
    def register cmd, opts={}, &blk
      @plugins ||= []
      @plugins << self.new(cmd, opts, &blk)
    end

    def check text
      @plugins.any? do |plugin|
        text =~ /^@(?:nkroid)\s+#{plugin.arg}/
      end
    end
  end
end

class FriendList < Plugin
end

class Event < Plugin
end

class DeletedTweet < Plugin
end

class Init < Plugin
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
    @@locker[self.id] ||= nil end
  def locker= locker
    @@locker[self.id] = locker end
  def locked?
    !!(@@locker[self.id] ||= nil) end
  def unlock
    @@locker[self.id] = nil end
end
