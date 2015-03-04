on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\stimer\s((?:\d|\.)+)\s*(sec|min|hour)/
		time, type = $1.to_i, $2.to_sym
		case type
		when :sec
			if time > 60 * 60
				mention(obj,"タイマーをセットできるのは1時間までです。")
			else
				mention(obj,"タイマーを#{time}秒にセットしました。")
				Thread.new do
					sleep time
					mention(obj,"#{time}秒経ちましたよ！")
				end
			end
		when :min
			if time > 60
				mention(obj,"タイマーをセットできるのは1時間までです。")
			else
				mention(obj,"タイマーを#{time}分にセットしました。")
				Thread.new do
					sleep time*60
					mention(obj,"#{time}分経ちましたよ！")
				end
			end
		when :hour
			if time > 1
				mention(obj,"タイマーをセットできるのは1時間までです。")
			else
				mention(obj,"タイマーを#{time}時間にセットしました。")
				Thread.new do
					sleep time*60*60
					mention(obj,"#{time}時間経ちましたよ！")
				end
			end
		end
	end
end