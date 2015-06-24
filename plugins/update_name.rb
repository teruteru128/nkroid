# coding: utf-8

def update_name(obj,name)
	$rest.update_profile(:name => name)
	obj.reply "#{name.gsub("@","@\u200b")}になりました。"
	prepare = "name#{obj.id}"
	$db.prepare(prepare,"insert into name (name,screen_name,time) values ($1,$2,$3)")
	$db.exec_prepared(prepare,[name,obj.user.screen_name,time])
	$db.exec("deallocate #{prepare};")
rescue => e
	obj.reply e.message
	$console.error e
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\supdate_name\s(.+)/
		update_name(obj,$1)
	when /^(?!RT)(.+)\(@#{screen_name}\)/
		update_name(obj,$1)
	when /^(?!RT)@#{screen_name}\srename\s(.+)/
		update_name(obj,$1)
	end
end
