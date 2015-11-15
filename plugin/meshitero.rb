$foods = twitter.user_timeline("meshiuma_yonaka",:count => 200)

Plugin.new(name: 'meshitero').on(:tweet) do |obj|
  text = obj.text
  next if text !~ /(おなか|腹)(す|空|減)|空腹|はらへ/
  next if text =~ /rt/i
  twitter.fav obj
  Thread.new do
    $foods.sample(3).each do |meshi|
      food = meshi.text.split[0]
      obj.reply "#{food}\n#{meshi.media[0].media_uri}"
    end
  end
end
