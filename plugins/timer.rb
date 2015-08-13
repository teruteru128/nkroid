command(/timer\s((?:\d|\.)+)\s*(sec|min|hour)/) do |obj|
	args = obj.args
	time,type = args[0].to_i,args[1].to_sym
	case type
	when :sec
		if time > 60 * 60
			obj.reply "タイマーをセットできるのは1時間までです。"
		else
			obj.reply "タイマーを#{time}秒にセットしました。"
			Thread.new do
				sleep time
				obj.reply "#{time}秒経ちましたよ！"
			end
		end
	when :min
		if time > 60
			obj.reply "タイマーをセットできるのは1時間までです。"
		else
			obj.reply "タイマーを#{time}分にセットしました。"
			Thread.new do
				sleep time*60
				obj.reply "#{time}分経ちましたよ！"
			end
		end
	when :hour
		if time > 1
			obj.reply "タイマーをセットできるのは1時間までです。"
		else
			obj.reply "タイマーを#{time}時間にセットしました。"
			Thread.new do
				sleep time*60*60
				obj.reply "#{time}時間経ちましたよ！"
			end
		end
	end
end