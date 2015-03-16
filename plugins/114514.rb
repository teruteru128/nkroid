require "open-uri"

url = 'https://114514.jp/114514.png'

on_event(:tweet) do |obj|
	if obj.text =~ /^(?!RT)@#{screen_name}\s+114514/
		@rest.update_profile_image(open(url))
		mention(obj,"イキスギィ！。\n#{Time.now}")
	end
end
