$events = {}
$commands = {}
$cmd_list = []

def on_event(event,opt={},&blk)
	$events[event] ||= []
	return if opt[:disable]
	$events[event] << blk
end

def command(cmd,opt={},&blk)
	$commands[cmd] = blk
	$cmd_list.push(/^(?!RT)@#{screen_name}\s+#{cmd}/)
end

def callback(event,obj)
	return if !$events[event]
	$events[event].each do |c|
		c.call(obj)
	end
end

def command_callback(obj)
	$commands.keys.each do |cmd|
		if obj.text =~ /^(?!RT)@#{screen_name}\s+#{cmd}/
			obj.args = [$1,$2,$3,$4,$5]
			$commands[cmd].call(obj)
		end
	end
rescue
	puts obj.text
end

def extract(obj)
	case obj
	when Twitter::Tweet
		return if obj.user.screen_name =~ screen_name
		callback(:tweet, obj)
		command_callback(obj)
	when Twitter::Streaming::Event
		callback(:event, obj)
	when Twitter::Streaming::FriendList
		$connected = true
	when Twitter::Streaming::DeletedTweet
		callback(:delete, obj)
	when Twitter::DirectMessage
		callback(:dm, obj)
	end
rescue Twitter::Error::Forbidden
	$accounts.fallback
rescue Twitter::Error::TooManyRequests
	post $!.class
	sleep 600
	return
rescue Twitter::Error::NotFound,Twitter::Error
	return
end