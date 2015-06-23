def screen_name
	/nkroid.*/
end

def twitter
	$accounts.cursor
end

def post(text)
	twitter.update(text)
rescue Twitter::Error
	$accounts.fallback
	retry
end

def mention(obj,texts,opt=false)
	pre = opt ? "." : ""
	texts.scan(/.{1,#{120}}/m).each do |text|
		twitter.update("#{pre}@#{obj.user.screen_name} #{text}",:in_reply_to_status_id => obj.id)
	end
rescue Twitter::Error
	$accounts.fallback
	retry
end