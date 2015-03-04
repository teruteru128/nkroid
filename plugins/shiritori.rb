require "sqlite3"
require "nkf"
require "uri"
require "rexml/document"
require "open-uri"
require "termcolor"

@dic = SQLite3::Database.open(@data + "/dic.db")
@natto = Natto::MeCab.new
@shiritori = Hash.new()

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

def furigana(word)
	url = "http://jlp.yahooapis.jp/FuriganaService/V1/furigana?appid=dj0zaiZpPUF4bHBKc29UTDNuMyZzPWNvbnN1bWVyc2VjcmV0Jng9NDk-&sentence=#{URI.encode(word)}"
	doc = REXML::Document.new(open(url))
	result = ""
	doc.elements.each("ResultSet/Result/WordList/Word/Furigana") do |e|
		result << e.text
	end
	result
end

def rand_dic
	ary=@dic.execute("SELECT * FROM dic ORDER BY RANDOM() LIMIT 1;")[0]
	ary[1][-1]=="ン" ? ["ねくろいど","ド"] : ary
end

def shiritori_by(first,userid)
	@dic.execute("SELECT * FROM dic WHERE reading LIKE '#{first}%' ORDER BY RANDOM();").each do |ary|
		return ary if (ary[1][-1] != ("ン" or "ー") and !@shiritori[userid].include?(ary[0]))
	end
	false
end

on_event(:tweet) do |obj|
	#しりとり開停始処理
	case obj.text
	when /^(?!RT)@#{screen_name}\s+しりとり開始/
		unless @shiritori[obj.user.id]
			word,reading = *rand_dic()
			mention(obj,"これより、しりとりを開始します。解除する場合は「しりとり終了」とリプライを送ってください。最初は、#{word}の「#{furigana(word).last_char}」からです♪\n#{Time.now}")
			@shiritori[obj.user.id] = Shiritori.new(word,reading.to_hira)
			puts "<Green>System -> Shiritori started!(vs @#{obj.user.screen_name},word:#{word})</Green>".termcolor
		else
			mention(obj,"すでにしりとりが開始されています。")
		end
	when /^(?!RT)@#{screen_name}\s+しりとり終了/
		if @shiritori[obj.user.id]
			mention(obj,"しりとりを終了します。お疲れ様でした。\n#{Time.now}")
			@shiritori.delete(obj.user.id)
		else
			mention(obj,"そもそもしりとりが開始されていません!")
		end
	end
end

on_event(:tweet) do |obj|
	#しりとりメイン処理
	next if cmd? obj.text
	next unless @shiritori[obj.user.id]
	if obj.text =~ /^(?!RT)@#{screen_name}\s+(.+)/
		word = $1
		if @shiritori[obj.user.id].include?(word)
			mention(obj,"#{word}はすでに使用されています。\n#{Time.now}")
			next
		end
		word_reading = furigana(word)
		last_reading = @shiritori[obj.user.id].last_reading
		if word_reading[0] != last_reading.last_char
			mention(obj,"#{word}(#{word_reading})は#{@shiritori[obj.user.id].last}(#{last_reading})に続きません。")
		elsif word_reading.last_char == "ん"
			mention(obj,"最後が「ん」(#{word_reading})なのであなたの負けです！これにてしりとりを終了します！\n#{Time.now}")
			@shiritori.delete(obj.user.id)
		else
			@shiritori[obj.user.id].push(word,word_reading)
			result = shiritori_by(word_reading.last_char.to_kana,obj.user.id)
			if result
				mention(obj,"\n#{word}(#{word_reading.to_kana})->#{result[0]}(#{result[1]})")
				@shiritori[obj.user.id].push(result[0],result[1].to_hira)
			else
				mention(obj,"負けました！あなたの勝ちです！\n#{Time.now}")
				@shiritori.delete(obj.user.id)
			end
		end
	end
end