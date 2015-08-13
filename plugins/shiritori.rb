require "sqlite3"
require "nkf"
require "uri"
require "rexml/document"
require "open-uri"
require "termcolor"
#require "natto"

$dic = SQLite3::Database.open($dir+"/data/dic.db")
#$natto = Natto::MeCab.new
$shiritori = Hash.new()

class Shiritori
	attr_reader :history,:last_reading,:last_char
	
	def initialize(first_word,first_read)
		@history=[]
		@history<<first_word
		@last_reading = first_read.upper
		@last_char = @last_reading.last_char
	end

	def push(word,reading)
		@history.push(word)
		@last_reading = reading.upper
	end

	def last
		@history.last
	end

	def include?(str)
		@history.include?(str)
	end
end

def rand_dic
	ary=$dic.execute("SELECT * FROM dic ORDER BY RANDOM() LIMIT 1;")[0]
	ary[1][-1]=="ン" ? ["ねくろいど","ド"] : ary
end

def shiritori_by(first,userid)
	$dic.execute("SELECT * FROM dic WHERE reading LIKE '#{first}%' ORDER BY RANDOM();").each do |ary|
		return ary if (ary[1][-1] != ("ン" or "ー") and !$shiritori[userid].include?(ary[0]))
	end
	false
end

command("しりとり開始") do |obj|
	unless $shiritori[obj.user.id]
		word,reading = *rand_dic()
		obj.reply "これより、しりとりを開始します。解除する場合は「しりとり終了」とリプライを送ってください。最初は、#{word}の「#{furigana(word).last_char}」からです♪\n#{Time.now}"
		$shiritori[obj.user.id] = Shiritori.new(word,reading.to_hira)
	else
		obj.reply "すでにしりとりが開始されています。"
	end
end

command("しりとり終了") do |obj|
	if $shiritori[obj.user.id]
		obj.reply "しりとりを終了します。お疲れ様でした。\n#{Time.now}"
		$shiritori.delete(obj.user.id)
	else
		obj.reply "そもそもしりとりが開始されていません!"
	end
end

on_event(:tweet) do |obj|
	#しりとりメイン処理
	next if cmd? obj.text
	next unless $shiritori[obj.user.id]
	if obj.text =~ /^(?!RT)@#{screen_name}\s+(.+)/
		word = $1
		if $shiritori[obj.user.id].include?(word)
			obj.reply "#{word}はすでに使用されています。\n#{Time.now}"
			next
		end
		word_reading = furigana(word)
		last_reading = $shiritori[obj.user.id].last_reading
		if word_reading[0] != last_reading.last_char
			obj.reply obj,"#{word}(#{word_reading})は#{$shiritori[obj.user.id].last}(#{last_reading})に続きません。"
		elsif word_reading.last_char == "ん"
			obj.reply "最後が「ん」(#{word_reading})なのであなたの負けです！これにてしりとりを終了します！\n#{Time.now}"
			$shiritori.delete(obj.user.id)
		else
			$shiritori[obj.user.id].push(word,word_reading)
			result = shiritori_by(word_reading.last_char.to_kana,obj.user.id)
			if result
				obj.reply "\n#{word}(#{word_reading.to_kana})->#{result[0]}(#{result[1]})"
				$shiritori[obj.user.id].push(result[0],result[1].to_hira)
			else
				obj.reply "負けました！あなたの勝ちです！\n#{Time.now}"
				$shiritori.delete(obj.user.id)
			end
		end
	end
end