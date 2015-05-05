# coding: utf-8

@count = Hash.new(0)

def save_name(sn,name,time)
	@db.execute <<-SQL
		CREATE TABLE IF NOT EXISTS name
			(screen_name TEXT, name TEXT, time TEXT)
	SQL
	@db.execute"INSERT INTO name VALUES (?,?,?)", [sn, name, time]
end

def update_name(obj,name)
	if @profile_locked
		mention(obj,"プロフィールは現在#{@locker}によってロックされています。\n#{time}")
		return
	end
	@rest.update_profile(:name => name)
	mention(obj,"#{name.gsub("@","@\u200b")}になりました。")
	save_name(obj.user.screen_name,name,time)
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
