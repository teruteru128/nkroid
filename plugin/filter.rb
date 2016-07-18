# サンプルプラグインです
# /12345/という正規表現にマッチしたツイートに"yo"と返信します

module Bot
  @filters = [
    /12345/
  ]

  on_tweet do |tweet, account|
    next if tweet.retweet?
    next unless @filters.any?{|filter|filter =~ tweet.text}
    tweet.reply "yo", account.rest
  end
end
