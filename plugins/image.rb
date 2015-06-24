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

def tweet_pic(obj,word)
	uri = search_image(word)
	if trust? obj.user.id
		$rest.fav(obj)
		twitter.update_with_media(
			"@#{obj.user.screen_name} #{word}の画像です #SearchImage",
			open(uri),
			:in_reply_to_status_id => obj.id
		)
	else
		obj.reply "#{word}の画像です #{uri} #SearchImage"
	end
rescue => e
	obj.reply e.message
	$console.error e
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)(.+?)(?:\s|\t)+画像/
		word = $1.gsub(/(\s+|　+|\t+)$/,"").gsub(/(の|な)$/,"")
		next if obj.text =~ /@|＠|RT|rt/
		tweet_pic(obj,word)
	when /^(?!RT)@#{screen_name}\simage\s(.+)/
		word = $1.gsub(/(\s|　|\t)+$/,"").gsub(/(の|な)$/,"")
		next if word =~ /@|＠|RT|rt/
		tweet_pic(obj,word)
	when /^(?!RT)@#{screen_name}\s+(.+?)(?:\s|の)?画像/
		word = $1.gsub("@","@\u200b")
		tweet_pic(obj,word)
	end
end

command(/それは違うよ|もっと/) do |obj|
	next if obj.in_reply_to_status_id === Twitter::NullObject
	if $rest.status(obj.in_reply_to_status_id).text =~ /\s(.+?)の画像です/
		word = $1
		tweet_pic(obj,word)
	else
		$rest.update("@#{obj.user.screen_name} #{@markov.text}",:in_reply_to_status_id => obj.id)
	end
end