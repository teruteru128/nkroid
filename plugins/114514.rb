require "open-uri"

url = 'https://114514.jp/114514.png'
url2 = 'https://114514.jp/1919.jpg'

on_event(:tweet) do |obj|
	if obj.text =~ /^(?!RT)@#{screen_name}\s+114514/
		@rest.update_profile_image(open(url))
		@rest.update_profile(:name => "田所浩二")
		@rest.update_profile(:location => "下北沢")
		@rest.update_profile(:url => "http://114514.com/")
		@rest.update_profile(:description => "24歳、学生です。水泳部と空手部に所属。")
		@rest.update_profile_banner(open(url2))
		mention(obj,"イキスギィ！。\n#{Time.now}")
	end
end
