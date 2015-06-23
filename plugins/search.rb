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
	twitter.update("@#{obj.user.screen_name} #{text}",:in_reply_to_status_id => obj.id)
end

def search_temp(obj)
	if obj.media?
		obj.media.each do|value|
			uri = value.media_uri.to_s
			res_uri = "http://www.google.co.jp/searchbyimage?image_url=#{uri}"
			mention(obj,"画像検索結果です\n#{res_uri}")
		end
	else
		obj.reply "画像が見つかりませんでした。画像を添付して、再実行してください。"
	end
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)(?!@)(.+?)\s+(?:検索|とは|#とは)/
		google($1,obj)
	when /^(?!RT)@#{screen_name}\s+search\s+(.+)/
		google($1,obj)
	when /(.+)\s*is何/
		google($1,obj)
	when /^(?!RT)@#{screen_name}\s+画像検索/
		search_temp(obj)
	end
end
