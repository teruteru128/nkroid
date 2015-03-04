# coding: utf-8

require "open-uri"

def default(obj,target,type)
	Thread.new do
		profile = YAML.load_file(@data+"/profile.yml")
		name, url, location, bio = profile[:name], profile[:url], profile[:location], profile[:bio]
		icon,header = @data+"/profile/#{target}_icon.png",@data+"/profile/#{target}_header.png"
		rest = rest_by(target)
		case type
		when "name"
			rest.update_profile(:name => name)
		when "bio"
			rest.update_profile(:description => bio)
		when "url"
			rest.update_profile(:url => url)
		when "location"
			rest.update_profile(:location => location)
		when "icon"
			File.open(icon){|file|rest.update_profile_image(file)}
		when "header"
			File.open(header){|file|rest.update_profile_banner(file)}
		when "all"
			rest.update_profile(:name => name, :url => url, :location => location, :description => bio)
			File.open(icon){|file|rest.update_profile_image(file)}
			File.open(header){|file|rest.update_profile_banner(file)}
		end
		if type == "all"
			text = "#{target}のプロフィールをデフォルトに戻しました"
		else
			text = "#{target}の#{type}をデフォルトに戻しました"
		end
		mention(obj,text)
	end
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@(#{screen_name})\s+default_(.+)/
		default(obj,$1,$2)
	when /^(?!RT)@(#{screen_name})\s+(デフォルト|でふぉ|でふぉると)/
		default(obj,$1,"all")
	end
end