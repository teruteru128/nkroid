# coding: utf-8

$db.prepare("update_name","insert into name values ($1,$2,$3)")

def update_name(obj,name)
	$rest.update_profile(:name => name)
	obj.reply "#{name.gsub("@","@\u200b")}になりました。"
	$db.exec_prepared("update_name",[name,obj.user.screen_name,time])
rescue => e
	obj.reply e.message
	$console.error e
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)(.+)\(@#{screen_name}\)/
		update_name(obj,$1)
	end
end

command(/(update_name|rename)\s(.+)/){|obj|update_name(obj,obj.args[1])}