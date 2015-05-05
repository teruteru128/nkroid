def admins
	str=File.read(@data+"/admins.txt")
	str.split("\n").map{|l|l.split[0].to_i}
end
def list
	@rest.users(*admins).map{|user|user.screen_name}.unshift("nkpoid")
end

def add_admin(id)
	user = @rest.user id
	userid,sn = user.id,user.screen_name
	open(@data+"/admins.txt","a"){|f|f.puts "#{userid}\s(#{sn})"}
	"@#{sn}(userid:#{userid})をsuに登録しました。"
rescue => e
	"#{e.class}\n#{e.message}"
end

def admin?(id)
	return true if id==850844893 #nkpoid
	admins.include? id
end

def block id
	user = @rest.user(id)
	return "suはブロックできません。" if admin? user.id
	@rest.block user
	"#{user.screen_name}さんをブロックしました。"
rescue => e
	"#{e.class}\n#{e.message}"
end
def unblock id
	user = @rest.user id
	@rest.unblock user
	"#{user.screen_name}さんへのブロックを解除しました。"
rescue => e
	"#{e.class}\n#{e.message}"
end

def r4s id
	user = @rest.user id
	@rest.report_spam user
	"#{user.screen_name}さんをスパム報告しました。"
rescue => e
	"#{e.class}\n#{e.message}"
end

@profile_locked = false

def execute_sudo(command,obj)
	case command
	when /profile\s+(lock|unlock)/
		case $1
		when "lock"
			@profile_locked = true
			@locker = obj.user.screen_name
		when "unlock"
			@profile_locked = false
		end
		mention(obj,"State of Profile:Lock->#{@profile_locked}")
	when /^block\s+(.+)/
		mention(obj,block($1)+"\n#{time}")
	when /unblock\s+(.+)/
		mention(obj,unblock($1)+"\n#{time}")
	when /register\s+su\s+(.+)/
		mention(obj,add_admin($1))
	when /(?:report_spam|r4s)\s+(.+)/
		mention(obj,r4s($1))
	when "stop"
		mention(obj,"bye.\n#{time}")
		exit
	else
		mention(obj,"Undefined.(#{command.split("\s")[0]})")
	end
rescue => e
	mention(obj,e.class)
end

on_event(:tweet) do |obj|
	if obj.text =~ /^(?!RT)@#{screen_name}\s+sudo\s+(.+)$/
		command = $1
		if admin? obj.user.id
			@rest.fav obj
			execute_sudo(command,obj)
		else
			mention(obj,"You don't have permission.\n#{time}")
		end
	end
end

on_event(:tweet) do |obj|
	if obj.text =~ /#{REPLY}list/
		mention(obj,"現在のねくろいど管理者:\n#{list.join("\n")}")
	end
end