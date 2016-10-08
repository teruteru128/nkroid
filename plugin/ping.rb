Tweet.hook do |tweet, account|
  if tweet.text =~ /ねくろいど|^@nkroid\s+ping/
    tweet.reply "pong(#{Time.now - decodeSnowflake(tweet.id)}s)", account.rest
  end
end
