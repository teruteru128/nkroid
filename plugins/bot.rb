# coding: utf-8
require "termcolor"

on_event(:tweet) do |obj|
	#tweet
	post(reply(obj.text)) if rand(299) == 0
end

REPLY = /^(?!RT)@#{screen_name}\s+/
COMMAND_LIST = [
	/#{REPLY}copy_(.+)\s+(.+)$/,
	/#{REPLY}default_(.+)/,
	/#{REPLY}(デフォルト|でふぉ|でふぉると)/,
	/#{REPLY}update_(icon|header)/,
	/#{REPLY}update_name\s(.+)/,
	/#{REPLY}rename\s(.+)/,
	/#{REPLY}image\s+(.+)/i,
	/#{REPLY}(icon_by_search|ibs)\s(.+)/,
	/#{REPLY}search/,
	/#{REPLY}(omikuji|おみくじ)/,
	/#{REPLY}tenki\s+(.+)/,
	/#{REPLY}((\d|\+|\-|\*|\/|\^|\(\d|\)|\!)+)/,
	/#{REPLY}timer\s((?:\d|\.)+)\s*(sec|min|hour)/,
	/#{REPLY}calc\s+(.+)/,
	/#{REPLY}(.+?)(?:\s|の)?画像/,
	/#{REPLY}しりとり開始/,
	/#{REPLY}しりとり停止/,
	/#{REPLY}sudo\s+(.+)$/
].freeze

WORD_LIST = [
	/^(.+)\(@#{screen_name}\)/,
	/デュエル/,
	/似てるの(なに|何)/,
	/これ(なに|何)/
].freeze

def cmd?(text)
	return true if text =~ WORD_LIST
	COMMAND_LIST.any?{|cmd| cmd =~ text }||$cmd_list.any?{|cmd| cmd =~ text }
end

on_event(:tweet) do |obj|
	#reply
	next if cmd?(obj.text)
	next if obj.uris?
	next if @shiritori[obj.user.id]
	case obj.text
	when /^(?!RT)@#{screen_name}\s+(.+)/
		next if obj.uris?
		obj.reply(reply($1))
	when /^(?!RT)@#{screen_name}\s*$/
		obj.reply $markov.text
	end
end