Plugin.new.command(/random|ランダム|らんだむ/) do |obj|
  res = Name.order("random()").limit(1).first
	accounts.main.update_profile(name: name)
	obj.reply("@#{res.screen_name}さんに#{res.created_at}につけられた「#{res.name.force_encoding("utf-8")}」に改名しました")
end
