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
	word = word.gsub(/(\s+|　+|\t+)$/,"").gsub(/(の|な)$/,"").gsub("@","@\u200b")
	url = search_image(word)
	text = "#{word}の画像です #{url} #SearchImage"
	obj.reply text
rescue => e
	obj.reply e.message
	$console.error e
end

on(:tweet) do |obj|
	case obj.text
	when /^(?!RT)(.+?)(?:\s|\t)+画像/
		word = $1.gsub(/(\s+|　+|\t+)$/,"").gsub(/(の|な)$/,"")
		next if obj.text =~ /@|＠|RT|rt/
		tweet_pic(obj,word)
	end
end

command(/image\s(.+)/){|obj|tweet_pic(obj,obj.args[0])}
command(/(.+?)(?:\s|の)?画像/){|obj|tweet_pic(obj,obj.args[0])}

command(/それは違うよ|もっと/) do |obj|
	next if obj.in_reply_to_status_id === Twitter::NullObject
	if $rest.status(obj.in_reply_to_status_id).text =~ /\s(.+?)の画像です/
		word = $1
		tweet_pic(obj,word)
	else
		$rest.update("@#{obj.user.screen_name} #{@markov.text}",:in_reply_to_status_id => obj.id)
	end
end
