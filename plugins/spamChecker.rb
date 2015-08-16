$spammer = Hash.new(0)

on_event(:tweet) do |obj|
	text = obj.text
	next if text =~ /^RT/
	next if text !~ /@null/
	next if text =~ /tweetbatt/
	user = obj.user
	next if trust? user.id
	$spammer[user.id] += 1
	if $spammer[user.id] < 3
		obj.reply "迷惑行為(null爆)を検知しました。あと#{3 - $spammer[user.id]}回同様の行為が確認できた場合、処置を行います。\n誤検知の場合は開発者までお知らせください。"
	else
		$accounts.accounts.each{|rest|rest.block user}
		$rest.dm("nkpoid","@#{user.screen_name} blocked")
	end
end
