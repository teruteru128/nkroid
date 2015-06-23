# coding: utf-8
require "open-uri"

def update_icon(obj, type)
	if @profile_locked
		mention(obj,"プロフィールは現在#{@locker}によってロックされています。\n#{time}")
		return
	end
	raise "画像を添付してください。" unless obj.media?
	uri = obj.media[0].media_uri.to_s+":orig"
	file = open(uri)
	case type
	when "icon"
		$rest.update_profile_image(file)
	when "header"
		$rest.update_profile_banner(file)
	else
		return
	end
	mention(obj,"#{type}を#{uri}に変更しました！")
rescue => e
	mention(obj,"#{e.message}\n#{Time.now}")
end

def icon_by_search(obj,q)
	if @profile_locked
		mention(obj,"プロフィールは現在#{@locker}によってロックされています。\n#{time}")
		return
	end
	uri = search_image(q)
	file = open(uri)
	$rest.update_profile_image(file)
	mention(obj,"アイコンを#{q}の検索結果に変更しました！\n#{uri}")
rescue => e
	mention(obj,e.message)
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\supdate_(icon|header)/
		update_icon(obj,$1)
	when /^(?!RT)@#{screen_name}\s(?:icon_by_search|ibs)\s(.+)/
		icon_by_search(obj,$1)
	end
end