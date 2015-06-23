# coding: utf-8
require "open-uri"

def copy(type,id,obj)
	copy_name = id.gsub("@","")
	raise "User not found" if !$rest.user?(copy_name)
	user = $rest.user id
	icon = user.profile_image_uri.to_s.gsub("_normal","")
	banner = user.profile_banner_uri.to_s.gsub("_normal","")
	time = Time.now.strftime("%x %H:%M:%S")
	case type
	when "name"
		$rest.update_profile(:name => user.name)
		text = "#{user.screen_name}(#{user.name})さんの名前をコピーしました！"
	when "icon"
		$rest.update_profile_image(open icon)
		text = "#{user.screen_name}(#{user.name})さんのアイコンをコピーしました！"
	when "all"
		$rest.update_profile(:name => user.name)
		$rest.update_profile_image(open icon)
		$rest.update_profile_banner(open banner)
		text = "#{user.screen_name}(#{user.name})さんのプロフィールをコピーしました！\n元に戻す際は私に向かって\"デフォルト\"とメンションを送ってください。"
	else
		text = "Format error"
	end
	obj.reply text
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+copy_(.+)\s+(.+)$/
		type,id = $1,$2
		copy(type, id, obj)
	end
end