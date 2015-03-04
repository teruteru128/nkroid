# coding: utf-8

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\sfallback\s+(.+)$/
		fallback $1
		next
	when /^(?!RT)@#{screen_name}\sfallback/
		fallback
	end
end
