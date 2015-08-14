# coding: utf-8
require "open-uri"

def copy(type,id,obj)
	Thread.new do
		twitter.fav obj
		sn = id.gsub("@","")
		sn = obj.user.screen_name if sn == "nkpoid"
		raise "User not found" if !$rest.user?(sn)
		user = $rest.user(sn)
		name,screen_name = user.name,user.screen_name
		icon = user.profile_image_uri(:original).to_s
		banner = user.profile_banner_uri(:'1500x500').to_s
		case type
		when "name"
			$rest.update_profile(:name => name)
			text = "#{screen_name}(#{name})さんの名前をコピーしました！"
		when "icon"
			$rest.update_profile_image(open(icon))
			text = "#{screen_name}(#{name})さんのアイコンをコピーしました！"
		when "all"
			$rest.update_profile(:name => name)
			$rest.update_profile_image(open(icon))
			$rest.update_profile_banner(open(banner)) if banner.length != 0
			text = "#{screen_name}(#{name})さんのプロフィールをコピーしました！\n元に戻す際は私に向かって\"デフォルト\"とメンションを送ってください。"
		else
			text = "Format error"
		end
		obj.reply text
	end
rescue
	obj.reply $!.message
end

command(/copy_(.+)\s+(.+)/) do |obj|
	args = obj.args[0,2]
	type,user = *args
	copy(type,user,obj)
end
