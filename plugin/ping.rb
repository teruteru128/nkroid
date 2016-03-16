module Bot
  @time_difference = lambda{Time.now - Time.at(((obj.id >> 22) + 1288834974657) / 1000.0)}
  command "ping" do |tweet|
    tweet.reply "ping!(#{@time_difference.call}sec)"
  end

  on_tweet do |tweet|
    tweet.reply "あの(#{@time_difference.call}秒)"
  end
end
