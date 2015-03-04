# coding: utf-8
require "termcolor"

on_event(:tweet) do |obj|
	time=t = Time.at(((obj.id >> 22) + 1288834974657) / 1000.0)
	puts "Tweet -> @#{obj.user.screen_name}: #{obj.text}\n#{time}\n<Red>Rag:#{Time.now-time}</Red>".termcolor
	next if obj.text =~ /rt|@/i
end