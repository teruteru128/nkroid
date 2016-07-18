module Bot
  on_tweet do |tweet, account|
    puts "@#{tweet.user.screen_name}: #{tweet.text}"
  end
end
