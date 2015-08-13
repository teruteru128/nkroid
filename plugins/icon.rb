# coding: utf-8
require "open-uri"

def update_icon(obj)
	raise "画像を添付してください。" if !obj.media?
	$rest.fav obj
	url = obj.media[0].media_uri.to_s
	file = open(url)
	type = obj.args[0]
	case type
	when "icon"
		$rest.update_profile_image(file)
	when "header"
		$rest.update_profile_banner(file)
	end
	sleep 1
	obj.reply "#{type}を#{url}に変更しました！"
rescue => e
	obj.reply e.message
	$console.error e
end

def icon_by_search(obj)
	q = obj.args[0]
	uri = search_image(q)
	file = open(uri)
	$rest.update_profile_image(file)
	obj.reply "アイコンを#{q}の検索結果に変更しました！\n#{uri}"
rescue => e
	obj.reply e.message
	$console.error e
end

command(/update_(icon|header)/){|obj|update_icon(obj)}
command(/(?:icon_by_search|ibs)\s(.+)/){|obj|icon_by_search(obj)}