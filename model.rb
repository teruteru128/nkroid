class Account
  attr_reader :rest, :stream, :screen_name
  def initialize(key)
    @rest = Twitter::REST::Client.new key
    @stream = Twitter::Streaming::Client.new key
    @screen_name = @rest.user.screen_name
  end
end

class Plugin
  @@plugins = {}
  @@readed = []

  attr_reader :proc
  def initialize type, opts={}, &blk
    @proc = blk
    @opts = opts
    @@plugins[type] ||= []
    @@plugins[type] << self
  end

  class << self
    def handle obj, account
      case obj
      when Twitter::Tweet
        return if @@readed.include?(obj.id)
        @@readed << obj.id
        @@readed.delete_at(0) if @@readed.size > 100

        return if @opts[:ignore_rt] && obj.retweet?
        callback :tweet, obj, account
        @@plugins[:tweet].each do |plugin|
          if obj.text =~ /^@(?:nkroid)\s+#{plugin.opts[:str]}/
            plugin.proc.call obj, account
          end
        end
      when Twitter::Streaming::FriendList
        callback :friendlist, obj, account
        @console.info "@#{account.screen_name} Stream connected."
      when Twitter::Streaming::Event
        callback :event, obj, account
      when Twitter::Streaming::DeletedTweet
        callback :deleted_tweet, obj, account
      end
    rescue
      return
    end

    def callback type, obj, account
      @@plugins[type].to_a.each do |plugin|
        plugin.proc.call obj, account
      end
    end
  end
end

class Twitter::Tweet
  def reply text, rest
    rest.update "@#{self.user.screen_name}\s"+text, in_reply_to_status: self
  end
end

def decodeSnowflake id
  Time.at(((id >> 22) + 1288834974657) / 1000.0)
end
