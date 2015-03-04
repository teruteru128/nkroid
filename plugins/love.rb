on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+(好き|結婚)/
		if rand(99) == 0
			mention(obj,"好き♡結婚しましょう！♡")
		else
			text = ["死ね","爆ぜろ","キモい"].sample + ["！","♪","¥"].sample
			mention(obj,text)
		end
	end
end