on_event(:tweet) do |obj|
	if obj.text =~ /ねくろいど/
		next if obj.text =~ /RT/
		time = Time.now - Time.at(((obj.id >> 22) + 1288834974657) / 1000.0)
		time = "0.11451419198100721" if rand(9999)==0
		mention(obj,"あの(#{time}秒)")
	elsif obj.text =~ /^(?!RT)@#{screen_name}\sping/
		t = Time.at(((obj.id >> 22) + 1288834974657) / 1000.0)
		mention(obj,"#{Time.now - t}sec")
	end
end