# coding: utf-8

on(:tweet) do |obj|
	#tweet
	post(reply(obj.text)) if rand(399) == 0
end

on(:tweet) do |obj|
	#reply
	next if cmd?(obj.text)
	next if obj.uris?
	next if $shiritori[obj.user.id]
	if obj.text =~ /^(?!RT)@#{screen_name}\s+(.*)/
		obj.reply reply($1)
	end
end
