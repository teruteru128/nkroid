Plugin.new.on(:tweet) do |obj|
	t = Time.at(((obj.id >> 22) + 1288834974657) / 1000.0)
	puts "Tweet -> @#{obj.user.screen_name}: #{obj.text}\n#{t}"
end
