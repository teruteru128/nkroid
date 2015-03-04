# coding: utf-8
require "open-uri"

def update_icon(obj, type)
	if obj.media?
		uri = obj.media[0].media_uri.to_s
		open(uri) do|file|
			pass = temp_io(file)
			io = File.open(pass)
			case type
			when "icon"
				@rest.update_profile_image(io)
			when "header"
				@rest.update_profile_banner(io)
			else
				return
			end
			mention(obj,"#{type}を#{uri}に変更しました！")
		end
	else
		mention(obj,"画像を添付してください。\n#{Time.now}")
	end
end

def icon_by_search(obj,q)
	uri = search_image(q)
	open(uri) do |io|
		pass = temp_io(io)
		if File.size?(pass) < 734003200
			file = File.open(pass)
			@rest.update_profile_image(file)
			mention(obj,"アイコンを#{q}の検索結果に変更しました！\n#{uri}")
			file.close
		else
			mention(obj,"Failed!\n#{Time.now}")
		end
	end
end

on_event(:tweet) do |obj| 
	case obj.text
	when /^(?!RT)@#{screen_name}\supdate_(icon|header)/
		update_icon(obj,$1)
	when /^(?!RT)@#{screen_name}\s(?:icon_by_search|ibs)\s(.+)/
		icon_by_search(obj,$1)
	end
end
