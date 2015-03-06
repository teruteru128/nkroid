# coding: utf-8
require "yaml"
require "termcolor"

on_event(:tweet) do |obj|
	#tweet
	post(@markov.reply(obj.text)) if rand(99) == 0
end

COMMAND_LIST = [
	/^(?!RT)@#{screen_name}\s+text\s+([\s\S]+)/,
	/^(?!RT)@#{screen_name}\s+copy_(.+)\s+(.+)$/,
	/^(?!RT)@#{screen_name}\s+default_(.+)/,
	/^(?!RT)@#{screen_name}\s+(デフォルト|でふぉ|でふぉると)/,
	/^(?!RT)@#{screen_name}\s+help/,
	/^(?!RT)@#{screen_name}\supdate_(icon|header)/,
	/^(?!RT)@#{screen_name}\s+(randum|random|ランダム|らんだむ)/i,
	/^(?!RT)@#{screen_name}\supdate_name\s(.+)/,
	/^(?!RT)(.+)\(@#{screen_name}\)/,
	/^(?!RT)@#{screen_name}\srename\s(.+)/,
	/^(?!RT)@#{screen_name}\s(?:image)\s+(.+)/i,
	/^(?!RT)@#{screen_name}\s(?:icon_by_search|ibs)\s(.+)/,
	/^(?!RT)@#{screen_name}\s+limit/,
	/^(?!RT)@#{screen_name}\s+count/,
	/^(?!RT)@#{screen_name}\s+search/,
	/^(?!RT)@#{screen_name}\s+(omikuji|おみくじ)/,
	/^(?!RT)@#{screen_name}\s+tenki\s+(.+)/,
	/^(?!RT)@#{screen_name}\s+(?:それは違うよ|もっと)/,
	/^(?!RT)@#{screen_name}\s((\d|\+|\-|\*|\/|\^|\(\d|\)|\!)+)/,
	/^(?!RT)@#{screen_name}\stimer\s((?:\d|\.)+)\s*(sec|min|hour)/,
	/^(?!RT)@#{screen_name}\s+.*(好き|結婚)/,
	/^(?!RT)@#{screen_name}\sping/,
	/^(?!RT)@#{screen_name}\s+bbop/,
	/^(?!RT)@#{screen_name}\s+gcus/,
	/^(?!RT)@#{screen_name}\s+画像検索/,
	/^(?!RT)@#{screen_name}\s+time/,
	/^(?!RT)@#{screen_name}\s+introduce/,
	/^(?!RT)@#{screen_name}\s(?:follow_me|フォロバ)/,
	/^(?!RT)@#{screen_name}\s+.+stop/,
	/^(?!RT)@#{screen_name}\s+calc\s+(.+)/,
	/^(?!RT)@#{screen_name}\s+black\s+(.+)/,
	/^(?!RT)@#{screen_name}\s+(.+?)(?:\s|の)?画像/,
	/^(?!RT)@#{screen_name}\s+しりとり開始/,
	/^(?!RT)@#{screen_name}\s+しりとり停止/,
	/デュエル/,
	/killme/,
].freeze

def cmd?(text)
	COMMAND_LIST.any?{|cmd| cmd =~ text }
end

on_event(:tweet) do |obj|
	next if cmd?(obj.text)
	next if @shiritori[obj.user.id]
	case obj.text
	when /^(?!RT)@#{screen_name}\s*$/
		mention(obj,@markov.text)
	when /^(?!RT)@#{screen_name}(.+)/
		next if obj.uris?
		t = $1
		mention(obj,@markov.reply(t))
	end
end

on_event(:tweet) do |obj|
	#learm
	text = obj.text
	next if obj.uris?
	next if obj.text =~ /@/
	next if text =~ /http|rt|batt|定期|自動|tweet|playing|バッテリー|充電|ポスト|リプライ|ねくろいど/i
	next if obj.source =~ /ifttt|auto|bot|play|プレ|ぷれ/i
	next if cmd? text
	next unless trust? obj.user.id
	text = text.gsub(/@\w+?/,"")
	Thread.new do
		@markov.add text
		puts "<Yellow>Learn -> #{text}</Yellow>".termcolor
	end
end