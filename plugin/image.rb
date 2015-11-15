require "open-uri"

def image(word)
  urls = []
  q = URI.encode(word)
  res = open("http://ajax.googleapis.com/ajax/services/search/images?q=#{q}&v=1.0&hl=ja&rsz=large&start=1&safe=off")
  JSON.load(res)["responseData"]["results"].each do |results|
    urls << results["url"]
  end
  urls.flatten.sample
end

class Twitter::Tweet
  def reply_pic_by_search(word)
    word = word.gsub(/(\s+|　+|\t+)$/,"").gsub(/(の|な)$/,"").gsub("@","@\u200b")
    self.reply "#{word}の画像です #{image(word)}"
  end
end

Plugin.new.on(:tweet) do |obj|
  next if obj.text !~ /^(?!RT)(.+?)(\s|\t)+画像/
  obj.reply_pic_by_search($1)
end

Plugin.new.command(/image\s(.+)/){|obj|obj.reply_pic_by_search(obj.args[0])}
Plugin.new.command(/(.+?)(?:\s|の)?画像/){|obj|obj.reply_pic_by_search(obj.args[0])}

Plugin.new.command(/それは違うよ|もっと/) do |obj|
  next if obj.in_reply_to_status_id === Twitter::NullObject
  if $rest.status(obj.in_reply_to_status_id).text =~ /\s(.+?)の画像です/
    obj.reply_pic_by_search($1)
  end
end
