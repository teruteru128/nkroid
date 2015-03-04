# coding: utf-8

require "open-uri"
require "fileutils"

def search_image(word)
	q = URI.encode(word)
	urls = []
	for i in 1..3
		open("http://ajax.googleapis.com/ajax/services/search/images?q=#{q}&v=1.0&hl=ja&rsz=large&start=#{i}&safe=off") do |file|
			JSON.load(file)["responseData"]["results"].each do |results|
				urls << results["url"]
			end
		end
	end
	url = urls.flatten.sample
	if url
		url
	else
		open("http://ajax.googleapis.com/ajax/services/search/images?q=#{URI.escape("見せられないよ")}&v=1.0&hl=ja&rsz=large&start=1&safe=on") do |file|
			JSON.load(file)["responseData"]["results"].each do |results|
				urls << results["url"]
			end
		end
		urls.flatten.sample
	end
end

def tweet_pic(obj,text,word)
	@rest.fav(obj)
	Thread.start do
		uri = search_image(word)
		open(uri) do |io|
			pass = temp_io(io)
			file = File.open(pass)
			twitter.update_with_media(text, file, :in_reply_to_status_id => obj.id)
			FileUtils.rm(file) #後処理
		end
	end
end

on_event(:tweet) do |obj|
	next if obj.text =~ /グロ/
	case obj.text
	when /^(?!RT)(.+?)(?:\s|\t)+画像/
		word = $1.gsub(/(\s+|　+|\t+)$/,"").gsub(/(の|な)$/,"")
		next if obj.text =~ /@|＠|RT|rt|;/
		text = "@#{obj.user.screen_name} #{word}の画像です #SearchImage"
		tweet_pic(obj,text,word)
	when /^(?!RT)@#{screen_name}\simage\s(.+)/
		word = $1.gsub(/(\s+|　+|\t+)$/,"").gsub(/(の|な)$/,"")
		next if word =~ /@|＠|RT|rt|グロ|;/
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