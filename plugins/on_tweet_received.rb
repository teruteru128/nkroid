# coding: utf-8
require "termcolor"

on(:tweet) do |obj|
	t = Time.at(((obj.id >> 22) + 1288834974657) / 1000.0)
	rag = Time.now - t
	raise if rag > 5
	$stderr.puts "Tweet -> @#{obj.user.screen_name}: #{obj.text}\n#{t}\n<Red>Rag:#{rag}</Red>".termcolor
end
