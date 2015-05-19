# -*- coding: utf-8 -*-
require 'open-uri'
require 'nokogiri'

 
icon_urls=[]
 
url = "http://anime-eupho.com/special/"
doc = Nokogiri::HTML.parse(open(url))
 
doc.css('img').each do |node|
	path = node.attributes["src"].value
	next if path !~ /special\/twitter\/thumb/
	path.gsub!("thumb","icon").gsub!("jpg","png")
	icon_urls << "http://anime-eupho.com"+path
end
 
 on_event(:tweet) do |obj|
	if obj.text =~ /^(?!RT)@#{screen_name}\s+eupho/
		if @profile_locked
			mention(obj,"プロフィールは現在#{@locker}によってロックされています。\n#{time}")
			next
		end
		@rest.update_profile_image(open(icon_urls))
		t = Time.now
		strTime = t.strftime("%H時 %M分 %S秒")
		mention(obj,"ユーフォニアムアイコン(#{icon_urls})に変更しました。\n#{strTime}")
	end
end