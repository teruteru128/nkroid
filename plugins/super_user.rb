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
	"#{user.screen_name}をブロックしました。"
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
	"#{user.screen_name}をスパム報告しました。"
rescue => e
	"#{e.class}\n#{e.message}"
end

@profile_locked = false

SUDO_COMMANDS = {
	/^profile\s+(lock|unlock)/ =>
		proc do |match, obj|
			@profile_locked = (match[1] == "lock")
			@locker = obj.user.screen_name if @profile_locked
			"State of Profile:Lock -> #@profile_locked"
		end,

	/^block\s+@?(\w+)/   => proc{|m| block m[1]},
	/^unblock\s+@?(\w+)/ => proc{|m| unblock m[1]},
	/^register\s+su\s+@?(\w+)/ => proc{|m| add_admin m[1]},
	/^(?:report_spam|r4s)\s+@?(\w+)/ => proc{|m| r4s m[1]},

	/^stop/ =>
		proc do
			mention(obj, "bye.\n#{time}")
			exit
		end,
}.freeze

def execute_sudo(command, obj)
	SUDO_COMMANDS.each do |regex, func|
		match = regex.match command
		if match
			if message = func.(match, obj)
				mention(obj, "#{message}\n#{time}")
			end
			return
		end
	end
	mention(obj, "Undefined. (#{command.split[0]})\n#{time}")
rescue => e
	mention(obj, e.class)
end

on_event(:tweet) do |obj|
	if obj.text =~ /^(?!RT)@#{screen_name}\s+sudo\s+(.+)$/
		command = $1
		if admin? obj.user.id
			@rest.fav obj
			execute_sudo(command, obj)
		else
			mention(obj, "You don't have permission.\n#{time}")
		end
	end
end

on_event(:tweet) do |obj|
	if obj.text =~ /#{REPLY}list/
		mention(obj, "現在のねくろいど管理者:\n#{list.join("\n")}")
	end
end