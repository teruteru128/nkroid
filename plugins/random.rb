# coding: utf-8

command(/random|ランダム|らんだむ/) do |obj|
	res = $db.exec("select * from name order by random() limit 1;")[0].values
	name,sn,time = *res
	$rest.update_profile(name: name)
	obj.reply("@#{sn}さんに#{time}につけられた「#{name}」に改名しました")
end