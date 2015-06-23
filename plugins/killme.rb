require "open-uri"

KILLME_REGEXP = %r(\Ahttp://aka\.saintpillia\.com/killme/icon/[0-9_-]{3,}\.png\z)

url = 'http://killmebaby.tv/special_icon.html'
html = open(url).read
doc = Nokogiri::HTML(html, url)

$killme = doc.css('img').map{|link| link[:src] }.select{|src| KILLME_REGEXP =~ src }

command("killme") do |obj|
	icon_url = $killme.sample
	$rest.update_profile_image(open(icon_url))
	obj.reply "キルミーアイコン(#{icon_url})に変更しました。\n#{time}"
end