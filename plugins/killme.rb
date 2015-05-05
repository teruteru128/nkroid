require "open-uri"

KILLME_REGEXP = %r(\Ahttp://aka\.saintpillia\.com/killme/icon/[0-9_-]{3,}\.png\z)

url = 'http://killmebaby.tv/special_icon.html'
html = open(url).read
doc = Nokogiri::HTML(html, url)

@killme = doc.css('img').map{|link| link[:src] }.select{|src| KILLME_REGEXP =~ src }

on_event(:tweet) do |obj|
	if obj.text =~ /^(?!RT)@#{screen_name}\s+killme/
		if @profile_locked
			mention(obj,"プロフィールは現在#{@locker}によってロックされています。\n#{time}")
			next
		end
		icon_url = @killme.sample
		@rest.update_profile_image(open(icon_url))
		mention(obj,"キルミーアイコン(#{icon_url})に変更しました。\n#{Time.now}")
	end
end
