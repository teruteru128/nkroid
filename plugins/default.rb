# coding: utf-8

def default(obj,target,type)
	$rest.fav obj
	icon,header = $dir+"/data/profile/nkroid_icon.png",$dir+"/data/profile/nkroid_header.png"
	case type
	when "name"
		$rest.update_profile(:name => "ねくろいど")
	when "icon"
		open(icon){|file|$rest.update_profile_image(file)}
	when "header"
		open(header){|file|$rest.update_profile_banner(file)}
	when "all"
		$rest.update_profile(:name => "ねくろいど")
		open(icon){|file|$rest.update_profile_image(file)}
		open(header){|file|$rest.update_profile_banner(file)}
	end
	if type == "all"
		text = "プロフィールをデフォルトに戻しました"
	else
		text = "#{type}をデフォルトに戻しました"
	end
	obj.reply text
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@(#{screen_name})\s+default_(.+)/
		default(obj,$1,$2)
	when /^(?!RT)@(#{screen_name})\s+(デフォルト|でふぉ|でふぉると)/
		default(obj,$1,"all")
	end
end