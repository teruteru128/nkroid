on_event(:tweet) do |obj|
	if obj.text =~ /ねくろいど/
		next if obj.text =~ /RT/
		next if obj.text =~ /天気/
		t = Time.at(((obj.id >> 22) + 1288834974657) / 1000.0)
		mention(obj,"あの(#{Time.now - t}秒)")
	elsif obj.text =~ /^(?!RT)@#{screen_name}\sping/
		t = Time.at(((obj.id >> 22) + 1288834974657) / 1000.0)
		mention(obj,"#{Time.now - t}sec")
	end
end