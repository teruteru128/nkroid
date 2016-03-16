module Bot
  @foods = rest.user_timeline("meshiuma_yonaka", count: 200)

  on_tweet do |tweet|
    next if tweet.retweet?
    next unless text =~ /(おなか|腹)(す|空|減)|空腹|はらへ/
    @foods.sample 3 do |food|
      food_name = food.text.split[0]
      tweet.reply "#{food_name}\s#{food.media[0].media_uri}"
    end
  end
end
