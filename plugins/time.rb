def ctime
	Time.now.strftime("%Y/%m/%d %R:%S.%L")
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+time/
		mention(obj,"現在の時刻は#{ctime}です。")
	when /今の時間/
		next if obj.text =~ /rt/i
		mention(obj,"現在の時刻は#{ctime}です。")
	end
end