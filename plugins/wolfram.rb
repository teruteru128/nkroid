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

on_event(:tweet) do |obj|
	case obj.text
	when /#{REPLY}(\d+)$/
		formula = $1
		t = Time.now
		result = prime(formula)
		if result.size != 0
			text = "#{formula}の素因数分解結果は#{result}です。"
		else
			text = "#{formula}の素因数分解に失敗しました。タイムアウトです。"
		end
		mention(obj,text+"\n#{Time.now-t}sec")
	when /^(?!RT)@#{screen_name}\s+calc\s+(.+)/
		formula = $1
		@rest.fav obj
		t = Time.now
		doc = Nokogiri::XML(open("http://api.wolframalpha.com/v2/query?input=#{CGI.escape(formula)}&appid=JY2U2Q-E8K7LG8KGR"))
		result = doc.xpath('//pod[@title="Result"]/subpod/plaintext').text
		mention(obj,"#{Time.now-t}sec\nInput:#{formula}\nResult:#{result}")
	end
end