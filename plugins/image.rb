# coding: utf-8

require "open-uri"

def image_url(word,n)
	urls = []
	q = URI.encode(word)
	for i in 1..n
		open("http://ajax.googleapis.com/ajax/services/search/images?q=#{q}&v=1.0&hl=ja&rsz=large&start=#{i}&safe=off") do |file|
			JSON.load(file)["responseData"]["results"].each do |results|
				urls << results["url"]
			end
		end
	end
	urls.flatten.sample
end

def search_image(word)
	url = image_url(word,2)
	url ? url : image_url("見せられないよ",1)
end

def tweet_pic(obj,text,word)
	@rest.fav(obj)
	Thread.start do
		uri = search_image(word)
		file = open uri
		twitter.update_with_media(text, file, :in_reply_to_status_id => obj.id)
		file.unlink
	end
rescue => e
	mention(obj,"#{e.class}\n#{e.message}\n#{time}")
end

on_event(:tweet) do |obj|
	next if obj.text =~ /グロ/
	case obj.text
	when /^(?!RT)(.+?)(?:\s|\t)+画像/
		word = $1.gsub(/(\s+|　+|\t+)$/,"").gsub(/(の|な)$/,"")
		next if obj.text =~ /@|＠|RT|rt/
		text = "@#{obj.user.screen_name} #{word}の画像です #SearchImage"
		tweet_pic(obj,text,word)
	when /^(?!RT)@#{screen_name}\simage\s(.+)/
		word = $1.gsub(/(\s|　|\t)+$/,"").gsub(/(の|な)$/,"")
		next if word =~ /@|＠|RT|rt/
		text = "@#{obj.user.screen_name} #{word}の画像です #SearchImage"
		tweet_pic(obj,text,word)
	when /^(?!RT)@#{screen_name}\s+(.+?)(?:\s|の)?画像/
		word = $1.gsub("@","@\u200b")
		text = "@#{obj.user.screen_name} #{word}の画像です #SearchImage"
		tweet_pic(obj,text,word)
	when /^(?!RT)@#{screen_name}\s*(?:それは違うよ|もっと)/
		next if obj.in_reply_to_status_id === Twitter::NullObject
		if @rest.status(obj.in_reply_to_status_id).text =~ /\s(.+?)の画像です/
			word = $1
			text = "@#{obj.user.screen_name} #{word}の画像です(Retry) #SearchImage"
			tweet_pic(obj,text,word)
		else
			@rest.update("@#{obj.user.screen_name} #{@markov.text}",:in_reply_to_status_id => obj.id)
		end
	end
end