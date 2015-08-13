# coding: utf-8

on_event(:tweet) do |obj|
	#tweet
	post(reply(obj.text)) if rand(299) == 0
end

def cmd?(text)
	$cmd_list.any?{|cmd|cmd =~ text}
end

on_event(:tweet) do |obj|
	#reply
	next if cmd?(obj.text)
	next if obj.uris?
	next if $shiritori[obj.user.id]
	if obj.text =~ /^(?!RT)@#{screen_name}\s+(.*)/
		obj.reply reply($1)
	end
end