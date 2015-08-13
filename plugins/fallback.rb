command("fallback") do |obj|
	$accounts.fallback
	obj.reply twitter.cursor.screen_name
end