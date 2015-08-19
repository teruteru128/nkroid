on(:tweet) do |obj|
  next if obj.user.screen_name != "nhk_news"
  next if obj.text !~ /just in/i
  twitter.retweet obj
end
