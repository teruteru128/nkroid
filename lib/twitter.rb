class Twitter::Tweet
  attr_accessor :args
  def reply(text, rest_user=Bot.rest)
    rest_user.update("@#{self.user.screen_name}\s#{text}", in_reply_to_status_id: self.id)
  end
end

module Bot
  class TwitterAccount
    attr_accessor :rest, :stream
    def initialize(key)
      @rest = Twitter::REST::Client.new key
      @stream = Twitter::Streaming::Client.new key
    end
  end

  @accounts = {}
  @stream_callbacks = {}
  @tweet_callbacks = []
  @command_callbacks = {}
  @readed = []

  keys = YAML.load_file('config/twitter_keys.yml')
  keys.each do |id, key|
    @accounts[id] = Bot::TwitterAccount.new(key)
  end

  module_function
  def rest
    @accounts.values.sample.rest
  end
  def screen_name
    /nkroid/
  end

  def on_tweet &blk
    @tweet_callbacks << blk
  end

  def command cmd, &blk
    @command_callbacks[cmd] ||= []
    @command_callbacks[cmd] << blk
  end
  def command_callback tweet, getter
    @command_callbacks.each do |cmd, procs|
      next unless tweet.text =~ /^@#{screen_name}\s+#{cmd}/i
      tweet.args = tweet.text.split.[2..-1]
      procs.each do |proc|
        proc.call tweet, getter
      end
    end
  end

  def extract obj, getter
    EM.defer do
      case obj
      when Twitter::Tweet
        next if obj.retweet?
        next if @readed.include? obj.id
        @readed << obj.id
        @readed.shift if @readed.length > 100
        @tweet_callbacks.each do |proc|
          proc.call obj, getter
        end
        command_callback tweet, getter
      when Twitter::Streaming::FriendList
        @console.info 'Stream connected.'
      end
    end
  end
end
