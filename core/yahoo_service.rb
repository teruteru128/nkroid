require "nkf"
require "open-uri"
require "rexml/document"
require "uri"
require "json"

YAPPID = ENV['YAPPID']

class String
  def furigana
    url = "http://jlp.yahooapis.jp/FuriganaService/V1/furigana?appid=dj0zaiZpPUF4bHBKc29UTDNuMyZzPWNvbnN1bWVyc2VjcmV0Jng9NDk-&sentence=#{URI.encode(self)}"
    doc = REXML::Document.new(open(url))
    result = ""
    doc.elements.each("ResultSet/Result/WordList/Word/Furigana") do |e|
        result << e.text
    end
    result
  end

  def keyphrase
    url = "http://jlp.yahooapis.jp/KeyphraseService/V1/extract?appid=#{YAPPID}&sentence=#{URI.encode(self)}"
    doc = REXML::Document.new(open(url))
    arr = []
    doc.elements.each("ResultSet/Result/Keyphrase") do |e|
        arr << e.text
    end
    arr.sample
  end
end
