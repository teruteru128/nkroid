require "open-uri"

url = 'http://killmebaby.tv/special_icon.html'
html = open(url).read
doc = Nokogiri::HTML(html, url)
@killme = []
doc.css('img').each{|link|@killme << link[:src] if /http:\/\/aka\.saintpillia\.com\/killme\/icon\/[0-9_-]{3,}\.png/ =~ link[:src]}

on_event(:tweet) do |obj|
	if obj.text =~ /^(?!RT)@#{screen_name}\s+killme/
		icon_url = @killme.sample
		@rest.update_profile_image(open(icon_url))
		mention(obj,"キルミーアイコン(#{icon_url})に変更しました。\n#{Time.now}")
	end
end