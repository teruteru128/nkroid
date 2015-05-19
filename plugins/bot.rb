# coding: utf-8
require "yaml"
require "termcolor"

on_event(:tweet) do |obj|
	#tweet
	post(@markov.reply(obj.text)) if rand(999) == 0
end

REPLY = /^(?!RT)@#{screen_name}\s+/
COMMAND_LIST = [
	/#{REPLY}text\s+([\s\S]+)/,
	/#{REPLY}copy_(.+)\s+(.+)$/,
	/#{REPLY}default_(.+)/,
	/#{REPLY}(デフォルト|でふぉ|でふぉると)/,
	/#{REPLY}help/,
	/#{REPLY}update_(icon|header)/,
	/#{REPLY}(randum|random|ランダム|らんだむ)/i,
	/#{REPLY}update_name\s(.+)/,
	/#{REPLY}rename\s(.+)/,
	/#{REPLY}image\s+(.+)/i,
	/#{REPLY}(icon_by_search|ibs)\s(.+)/,
	/#{REPLY}limit/,
	/#{REPLY}count/,
	/#{REPLY}search/,
	/#{REPLY}(omikuji|おみくじ)/,
	/#{REPLY}tenki\s+(.+)/,
	/#{REPLY}それは違うよ|もっと/,
	/#{REPLY}((\d|\+|\-|\*|\/|\^|\(\d|\)|\!)+)/,
	/#{REPLY}timer\s((?:\d|\.)+)\s*(sec|min|hour)/,
	/#{REPLY}.*(好き|結婚)/,
	/#{REPLY}ping/,
	/#{REPLY}bbop/,
	/#{REPLY}gcus/,
	/#{REPLY}画像検索/,
	/#{REPLY}time/,
	/#{REPLY}(?:follow_me|フォロバ)/,
	/#{REPLY}.+stop/,
	/#{REPLY}calc\s+(.+)/,
	/#{REPLY}black\s+(.+)/,
	/#{REPLY}(.+?)(?:\s|の)?画像/,
	/#{REPLY}しりとり開始/,
	/#{REPLY}しりとり停止/,
	/#{REPLY}これ(なに|何)/,
	/#{REPLY}killme/,
	/#{REPLY}sudo\s+(.+)$/,
	/#{REPLY}list/,
].freeze

WORD_LIST = [
	/^(.+)\(@#{screen_name}\)/,
	/デュエル/,
	/似てるの(なに|何)/
].freeze

def cmd?(text)
	return true if text =~ WORD_LIST
	COMMAND_LIST.any?{|cmd| cmd =~ text }
end

on_event(:tweet) do |obj|
	#reply
	next if cmd?(obj.text)
	next if obj.uris?
	next if @shiritori[obj.user.id]
	case obj.text
	when /^(?!RT)@#{screen_name}\s*$/
		mention(obj,@markov.text)
	when /^(?!RT)@#{screen_name}\s+(.+)/
		next if obj.uris?
		mention(obj,@markov.reply($1))
	end
end