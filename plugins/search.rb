# coding: utf-8
require "open-uri"
require "nokogiri"
require 'uri'
require "net/http"
require "cgi"
require "sanitize"

def google(word,obj)
	url = URI.encode("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{word}")
	result = []
	open(url) do |file|
		result = JSON.load(file)["responseData"]["results"][0]
	end
	text = "#{result["titleNoFormatting"]}\n#{Sanitize.clean(result["content"])[0,39]}\n#{result["unescapedUrl"]}".gsub("@","@\u200b")
	obj.reply text
end

on_event(:tweet) do |obj|
	next if obj.text =~ /rt|@/i
	case obj.text
	when /(.+)\s+(?:検索|とは|#とは)/
		google($1,obj)
	when /(.+)\s*(?:is|って)何$/
		google($1,obj)
	end
end

command(/search\s+(.+)/){|obj|google(obj.args[0],obj)}
