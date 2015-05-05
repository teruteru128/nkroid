# encoding: utf-8
require "nkf"
require "open-uri"
require "sqlite3"
require "rexml/document"
require "uri"
require "natto"

BEGIN_FLG = '[BEGIN]'
END_FLG = '[END]'

class Markov
	attr_reader :natto
	def initialize
		@db = SQLite3::Database.open(File.expand_path("../data", __FILE__)+"/markov.db")
		@natto = Natto::MeCab.new
	end

	def text
		selected = @db.execute("SELECT * FROM japanese WHERE one = '#{BEGIN_FLG}' ORDER BY RANDOM() LIMIT 1")[0]
		markov_text = selected[1] + selected[2]
		while true
			selected = @db.execute("SELECT * FROM japanese WHERE one = '#{selected[2]}' ORDER BY RANDOM() LIMIT 1")[0]
			break if selected.empty?
			if selected[2] == END_FLG
				markov_text << selected[1]
				break
			else
				markov_text << selected[1] << selected[2]
			end
		end
		markov_text
	rescue
		retry
	end
	
	def keyphrase(sentence)
		url = "http://jlp.yahooapis.jp/KeyphraseService/V1/extract?appid=dj0zaiZpPUF4bHBKc29UTDNuMyZzPWNvbnN1bWVyc2VjcmV0Jng9NDk-&sentence=#{URI.encode(sentence)}"
		doc = REXML::Document.new(open(url))
		arr = []
		doc.elements.each("ResultSet/Result/Keyphrase") do |e|
			arr << e.text
		end
		arr.sample
	end
	
	def useof(word)
		selected = @db.execute("SELECT * FROM japanese WHERE one = '#{BEGIN_FLG}' AND (two = '#{word}' OR three = '#{word}') ORDER BY RANDOM() LIMIT 1")[0]
		markov_text = selected[1] + selected[2]
		while true
			selected = @db.execute("SELECT * FROM japanese WHERE one = '#{selected[2]}'ORDER BY RANDOM() LIMIT 1")[0]
			return false if selected.nil?
			if selected[2] == END_FLG
				markov_text << selected[1]
				break
			else
				markov_text << selected[1] << selected[2]
			end
		end
		markov_text
	end

	def reply(text)
		key = keyphrase text
		if key
			t = useof key
			t = t ? t : text()
		else
			t = text()
		end
		return t
	rescue Exception => e
		return text()
	end

	def add(text)
		@db.execute <<-SQL
			CREATE TABLE IF NOT EXISTS japanese
				(one TEXT, two TEXT, three TEXT)
		SQL
		markov_arr = []
		wakati_arr = []
		wakati_arr << BEGIN_FLG
		@natto.parse(text) do |n|
			s=n.surface
			wakati_arr << s if s
		end
		wakati_arr << END_FLG
		return if wakati_arr.size < 4
		i,index = 0,0
		while wakati_arr[i+1] != END_FLG
			markov_arr[index] = []
			markov_arr[index] << wakati_arr[i]
			markov_arr[index] << wakati_arr[i+1]
			markov_arr[index] << wakati_arr[i+2]
			index += 1;i += 1
		end
		markov_arr.each do |arr|
			@db.execute"INSERT INTO japanese VALUES (?,?,?)", arr
		end
	end
end