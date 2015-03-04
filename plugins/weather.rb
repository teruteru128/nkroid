require "weather_jp"

on_event(:tweet) do |obj|
	next if obj.text =~ /RT/
	case obj.text
	when /天気/
		Thread.new do
			text = WeatherJp.parse(obj.text.gsub(/@.+?\s/,"")).to_s
			mention(obj,text) if text.size != 0
		end
	when /^(?!RT)@#{screen_name}\s+tenki\s+(.+)/
		place = $1
		Thread.new do
			weather = WeatherJp.get(place)
			if weather
				mention(obj,weather.today.to_s)
			else
				mention(obj,"#{place}の天気情報は見つかりませんでした。")
			end
		end
	when /おはよ|起床|起き(まし)?た/
		next if obj.text =~ /@/
		user = obj.user
		next if user.location.class != String
		weather = WeatherJp.get(user.location)
		next unless weather
		mention(obj,"#{user.name}さん、おはようございます！#{weather.today.to_s}")
	when /おやすみ|寝(ます|る$)/
		next if obj.text =~ /@/
		user = obj.user
		next if user.location.class != String
		weather = WeatherJp.get(user.location)
		next unless weather
		mention(obj,"#{user.name}さん、おやすみなさい！#{weather.tomorrow.to_s}")
	end
end