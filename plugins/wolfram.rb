require "open-uri"
require "json"
require "rexml/document"
require "uri"
require "nokogiri"
require "cgi"
require "prime"

def prime(num)
	if num == "1"
		"1(isn't prime number)"
	else
		arr = []
		results = Prime.prime_division(num.to_i)
		results.each do |pri|num
			t = pri[1] == 1 ? "" : "^#{pri[1]}"
			arr << pri[0].to_s + t
		end
		prime_suffix = (results.size == 1 and results[0][1] == 1) ? "(prime number)" : ""
		(arr.join("×") + prime_suffix)
	end
rescue => e
	""
end

command(/^(\d+)$/) do |obj|
	$rest.fav obj
	num = obj.args[0]
	t = Time.now
	result = prime(num)
	if result.size != 0
		text = "#{num}の素因数分解結果は#{result}です。"
	else
		text = "#{num}の素因数分解に失敗しました。タイムアウトです。"
	end
	obj.reply text+"\n#{Time.now-t}sec"
end

command(/calc\s+(.+)/) do |obj|
	$rest.fav obj
	formula = obj.args[0]
	t = Time.now
	doc = Nokogiri::XML(open("http://api.wolframalpha.com/v2/query?input=#{CGI.escape(formula)}&appid=JY2U2Q-E8K7LG8KGR"))
	result = doc.xpath('//pod[@title="Result"]/subpod/plaintext').text
	obj.reply "#{Time.now-t}sec\nInput:#{formula}\nResult:#{result}"
end