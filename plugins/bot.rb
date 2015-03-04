# coding: utf-8
require "yaml"
require "termcolor"

on_event(:tweet) do |obj|
	#tweet
	post(@markov.reply(obj.text)) if rand(99) == 0
end

def cmd?(text)
	q = true
	case text
	when /^(?!RT)@#{screen_name}\s+text\s+([\s\S]+)/
	when /^(?!RT)@#{screen_name}\s+copy_(.+)\s+(.+)$/
	when /^(?!RT)@#{screen_name}\s+default_(.+)/
	when /^(?!RT)@#{screen_name}\s+(デフォルト|でふぉ|でふぉると)/
	when /^(?!RT)@#{screen_name}\s+help/
	when /^(?!RT)@#{screen_name}\supdate_(icon|header)/
	when /^(?!RT)@#{screen_name}\s+(randum|random|ランダム|らんだむ)/i
	when /^(?!RT)@#{screen_name}\supdate_name\s(.+)/
	when /^(?!RT)(.+)\(@#{screen_name}\)/
	when /^(?!RT)@#{screen_name}\srename\s(.+)/
	when /^(?!RT)@#{screen_name}\s(?:image)\s+(.+)/i
	when /^(?!RT)@#{screen_name}\s(?:icon_by_search|ibs)\s(.+)/
	when /^(?!RT)@#{screen_name}\s+limit/
	when /^(?!RT)@#{screen_name}\s+count/
	when /^(?!RT)@#{screen_name}\s+search/
	when /^(?!RT)@#{screen_name}\s+(omikuji|おみくじ)/
	when /^(?!RT)@#{screen_name}\s+tenki\s+(.+)/
	when /^(?!RT)@#{screen_name}\s+(?:それは違うよ|もっと)/
	when /^(?!RT)@#{screen_name}\s((\d|\+|\-|\*|\/|\^|\(\d|\)|\!)+)/
	when /^(?!RT)@#{screen_name}\stimer\s((?:\d|\.)+)\s*(sec|min|hour)/
	when /^(?!RT)@#{screen_name}\s+.*(好き|結婚)/
	when /^(?!RT)@#{screen_name}\sping/
	when /^(?!RT)@#{screen_name}\s+bbop/
	when /^(?!RT)@#{screen_name}\s+gcus/
	when /^(?!RT)@#{screen_name}\s+画像検索/
	when /^(?!RT)@#{screen_name}\s+time/
	when /^(?!RT)@#{screen_name}\s+introduce/
	when /^(?!RT)@#{screen_name}\s(?:follow_me|フォロバ)/
	when /^(?!RT)@#{screen_name}\s+.+stop/
	when /^(?!RT)@#{screen_name}\s+calc\s+(.+)/
	when /^(?!RT)@#{screen_name}\s+black\s+(.+)/
	when /^(?!RT)@#{screen_name}\s+(.+?)(?:\s|の)?画像/
	when /^(?!RT)@#{screen_name}\s+しりとり開始/
	when /^(?!RT)@#{screen_name}\s+しりとり停止/
	when /デュエル/
	when /killme/
	else
		q = false
	end
	return q
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