require "open-uri"

Thread.new do
	while true
		$foods = $rest.user_timeline("meshiuma_yonaka",:count => 200)
		sleep 60*60
	end
end

on_event(:tweet) do |obj|
	case obj.text
	when /(おなか|腹)(す|空|減)|空腹|はらへ/
		next if obj.text =~ /rt/i
		$rest.fav obj
		Thread.new do
			$foods.sample(3).each do |meshi_obj|
				food = meshi_obj.text.split[0]
				twitter.update_with_media("@#{obj.user.screen_name}\s#{food}", open(meshi_obj.media[0].media_uri.to_s), :in_reply_to_status_id => obj.id)
			end
		end
	end
end