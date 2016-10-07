Plugin.new :tweet do |tweet, account|
  next if obj.text !~ /ねくろいど|^@nkroid\s+ping/
  tweet.reply "ping(#{decodeSnowflake(tweet.id)})", account.rest
end
