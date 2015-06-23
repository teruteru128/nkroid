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

def extract_obj(obj)
	case obj
	when Twitter::Tweet
		return if obj.user.screen_name =~ screen_name
		callback(:tweet, obj)
		$commands.keys.each do |cmd|
			$commands[cmd].call(obj) if obj.text =~ /^(?!RT)@#{screen_name}\s+#{cmd}/
		end
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
	retry
rescue Twitter::Error::TooManyRequests => e
	sleep e.rate_limit.reset_in
	return 
rescue Twitter::Error::NotFound
	return
rescue Twitter::Error
	retry
end
