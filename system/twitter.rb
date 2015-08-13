def screen_name
	/nkroid.*/ end

def twitter
	$accounts.cursor end

def post(text)
	twitter.update(text)
rescue Twitter::Error
	$accounts.fallback
	retry
end