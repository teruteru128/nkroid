on_event(:tweet) do |obj|
	if obj.text =~ /ねくろいど/
		next if obj.text =~ /^RT/
		time = Time.now - Time.at(((obj.id >> 22) + 1288834974657) / 1000.0)
		obj.reply "あの(#{time}秒)"
	end
end

command("ping") do |obj|
	t = Time.at(((obj.id >> 22) + 1288834974657) / 1000.0)
	obj.reply "pong(#{Time.now - t}sec)"
end