$cmd_list = []

class EventListener
	def initialize
		@events = {}
	end

	def on(event, opt={}, &blk)
		@events[event] ||= []
		return if opt[:disable]
		@events[event] << blk
	end

	def callback(event, obj)
		return if !@events[event]
		@events[event].each do |c|
			c.call(obj)
		end
	rescue
		$console.error $!
	end
end

class CommandProcessor
	def initialize
		@commands = {}
	end

	def command(cmd, opt={}, &blk)
		@commands[cmd] = {opt: opt,proc: blk}
		$cmd_list.push(/^(?!RT)@#{screen_name}\s+#{cmd}/)
	end

	def callback(obj)
		@commands.keys.each do |cmd|
			next if obj.text !~ /^(?!RT)@#{screen_name}\s+#{cmd}/
			case cmd
			when String
				obj.text =~ /^(?!RT)@#{screen_name}\s+#{cmd}(?:\s(.+))?/
				obj.args = $1.split
			when Regexp
				obj.args = [$1,$2,$3,$4,$5]
			end
			opt = @commands[cmd][:opt]
			@commands[cmd][:proc].call(obj)
		end
	rescue
		obj.reply $!.message.to_s
	end
end

@event = EventListener.new
@command = CommandProcessor.new

def on(*args)
	@event.on(*args)
end
alias :on_event :on

def command(*args)
	@command.command(*args)
end

def cmd?(text)
	$cmd_list.any?{|cmd|cmd =~ text}
end

def extract(obj)
	case obj
	when Twitter::Tweet
		return if obj.user.screen_name =~ screen_name
		@event.callback(:tweet, obj)
		@command.callback(obj)
	when Twitter::Streaming::Event
		@event.callback(:event, obj)
	when Twitter::Streaming::FriendList
		$following = obj
	when Twitter::Streaming::DeletedTweet
		@event.callback(:delete, obj)
	when Twitter::DirectMessage
		@event.callback(:dm, obj)
	end
rescue Twitter::Error::Forbidden
	$accounts.fallback
rescue Twitter::Error::TooManyRequests
	sleep 600
	return
rescue Twitter::Error::NotFound,Twitter::Error
	return
end
