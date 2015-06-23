require "nkf"
require "open-uri"
require "rexml/document"
require "uri"
require "json"

YAPPID = "dj0zaiZpPUF4bHBKc29UTDNuMyZzPWNvbnN1bWVyc2VjcmV0Jng9NDk-"

def keyphrase(sentence)
	url = "http://jlp.yahooapis.jp/KeyphraseService/V1/extract?appid=#{YAPPID}&sentence=#{URI.encode(sentence)}"
	doc = REXML::Document.new(open(url))
	arr = []
	doc.elements.each("ResultSet/Result/Keyphrase") do |e|
		arr << e.text
	end
	arr.sample
end

def geocoder(query)
	url = "http://contents.search.olp.yahooapis.jp/OpenLocalPlatform/V1/contentsGeoCoder?appid=#{YAPPID}&query=#{URI.encode(query)}&output=json"
	res = JSON.parse(open(url).read)
	return false if res["ResultInfo"]["Count"] == 0
	[res["Feature"]["Name"],res["Feature"]["Geometry"]["Coordinates"].split(",")]
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