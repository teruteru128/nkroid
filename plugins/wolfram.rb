require "open-uri"
require "json"
require "rexml/document"
require "uri"
require "nokogiri"
require "cgi"
require "prime"
require "timeout"

def alpha(q,x)
	url = "http://api.wolframalpha.com/v2/query?input=#{CGI.escape(q)}&appid=JY2U2Q-E8K7LG8KGR"
	doc = Nokogiri::XML(open(url))
	return doc.xpath(x).text
end

def prime_calc(formula)
	if formula =~ /^\d+$/ and formula.size < 20
		arr = []
		results = Prime.prime_division(formula.to_i)
		results.each do |pri|
			t = pri[1] == 1 ? "" : "^#{pri[1]}"
			arr << pri[0].to_s + t
		end
		prime_suffix = (results.size == 1 and results[0][1] == 1) ? "(prime number)" : ""
		return (arr.join("×") + prime_suffix)
	else
		n = formula =~ /^\d+$/ ? formula : alpha(formula,'//pod[@title="Result"]/subpod/plaintext')
		return alpha(n,'//pod[@title="Prime factorization"]/subpod/plaintext')
	end
end

def prime(formula)
	if formula == "1"
		return "1(isn't prime number)"
	elsif formula =~ /^(\d+)\^(\d+)$/
		n1,n2 = $1,$2
		arr = []
		results = Prime.prime_division(n1.to_i)
		results.each do |pri|
			t = pri[1] == 1 ? "" : "^#{pri[1]}"
			arr << pri[0].to_s + t
		end
		pare= arr.size == 1 ? ["",""] : ["(",")"]
		return "#{pare[0]}#{arr.join("×")}#{pare[1]}^#{n2}"
	else
		return prime_calc(formula)#.gsub(/\^|×|÷/,{"^"=>"**","÷"=>"/","×"=>"*"}))
	end
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s((\d|\+|\-|\*|\/|\^|\(\d|\))+)/
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
		t = Time.now
		doc = Nokogiri::XML(open("http://api.wolframalpha.com/v2/query?input=#{CGI.escape(formula)}&appid=JY2U2Q-E8K7LG8KGR"))
		result = doc.xpath('//pod[@title="Result"]/subpod/plaintext').text
		roots = doc.xpath('//pod[@title="Roots"]/subpod/plaintext').text
		ary = [];doc.text.split(/\s\s/).each{|text|ary<<text if text=~/\s=\s/}
		x = ary.nil? ? "" : ary.join(",")
		if x != ""
			text = x
		elsif result != ""
			text = result
		elsif roots != ""
			text = roots
		else
			text = "Calculation failed"
		end
		mention(obj,"Input:#{formula}\nResult:#{text}\n#{Time.now - t}sec")
	end
end