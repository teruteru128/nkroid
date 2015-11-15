require "base64"

Plugin.new.command(/base64\s+(e|d)\s+(.+)/) do |obj|
	type,str = *obj.args[0,2]
	text = case type
	when "e"
		Base64.encode64(str)
	when "d"
		Base64.decode64(str)
	end
	obj.reply text
end
