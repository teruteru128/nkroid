module Bot
  class TwitterAccount
    attr_reader :screen_name, :rest, :stream, :streaming
    def initialize(key)
      @rest = Twitter::REST::Client.new key
      @stream = Twitter::Streaming::Client.new key
      @screen_name = @rest.user.screen_name
      @streaming = !key["not_stream"]
    end
  end

  @accounts = []
  @stream_callbacks = {}
  @tweet_callbacks = []
  @readed = []

  conf = YAML.load_file('config/twitter_keys.yml')
  conf.values.each do |key|
    @accounts << Bot::TwitterAccount.new(key)
  end

  class << self
    def account(name)
      @accounts.find{|it|it.screen_name == name}
    end

    def on name, &blk
      @stream_callbacks[name] ||= []
      @stream_callbacks[name] << blk
    end

    def on_tweet &blk
      @tweet_callbacks << blk
    end

    def extract obj, account
      case obj
      when Twitter::Tweet
        tweet = obj.retweet? ? obj.retweeted_status : obj
        @readed.include?(tweet.id) ? return : @readed << tweet.id
        @tweet_callbacks.each do |proc|
          proc.call tweet, account
        end
      when Twitter::Streaming::FriendList
        @console.info "@#{account.screen_name} Stream connected."
      when Twitter::Streaming::Event
        @stream_callbacks[:event].to_a.each do |proc|
          proc.call obj, account
        end
      when Twitter::Streaming::DeletedTweet
        @stream_callbacks[:deleted_tweet].to_a.each do |proc|
          proc.call obj, account
        end
      end
    rescue
      report $!
      return
    end
  end
end

class Twitter::Tweet
  # text: String a reply message
  # rest: Twitter::REST::Client a instance of source user
  def reply text, rest
    rest.update "@#{self.user.screen_name}\s"+text, in_reply_to_status: self
  end
end
