require "open-uri"
require 'uri'
require "net/http"

class Twitter::Tweet
  def google(word)
  	url = URI.encode("http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=#{word}")
  	result = []
  	open(url) do |file|
  		result = JSON.load(file)["responseData"]["results"][0]
  	end
  	text = "#{result["titleNoFormatting"]}\n#{Sanitize.clean(result["content"])[0,39]}\n#{result["unescapedUrl"]}".gsub("@","@\u200b")
  	self.reply text
  end
end

Plugin.new.on(:tweet) do |obj|
	next if obj.text =~ /rt|@/i
	case obj.text
	when /(.+)\s+(?:検索|とは|#とは)/
		obj.google($1)
	when /(.+)\s*(?:is|って)何$/
		obj.google($1)
	end
end

Plugin.new(name:"GoogleSearch").command(/search\s+(.+)/){|obj|obj.google(obj.args[0])}
