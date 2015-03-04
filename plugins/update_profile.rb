# coding: utf-8

def save_name(sn,name,time)
	@db.execute <<-SQL
		CREATE TABLE IF NOT EXISTS name
			(screen_name TEXT, name TEXT, time TEXT)
	SQL
	@db.execute"INSERT INTO name VALUES (?,?,?)", [sn, name, time]
end

def update_profile(obj,str)
	unless trust?(obj.user.id)
		mention(obj,"現在、update機能は特定の方しかご利用になれません。\n#{Time.now}")
		return
	end
	@rest.update_profile(:name => str)
	mention(obj,"#{str.gsub("@","@\u200b")}になりました。")
	save_name(obj.user.screen_name,str,Time.now.strftime("%Y-%m-%d %H:%M:%S"))
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\supdate_name\s(.+)/
		update_profile(obj,$1)
	when /^(?!RT)(.+)\(@#{screen_name}\)/
		update_profile(obj,$1)
	when /^(?!RT)@#{screen_name}\srename\s(.+)/
		update_profile(obj,$1)
	end
end
