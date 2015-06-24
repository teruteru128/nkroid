$spamer = Hash.new(0)

on_event(:tweet) do |obj|
	text = obj.text
	next if text !~ /@null/
	user = obj.user
	next if trust? user.id
	$spamer[user.id] += 1
	if $spamer[user.id] < 10
		obj.reply "迷惑行為を検知しました。あと#{10 - $spamer[user.id]}回同様の行為が確認できた場合、処置を行います。"
	else
		$accounts.accounts.each{|rest|rest.block user}
		$console.info "@#{user.screen_name} blocked"
	end
end