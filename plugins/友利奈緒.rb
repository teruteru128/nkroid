def 友利奈緒(obj)
	twitter.fav obj
	image = Dir.glob("./data/友利奈緒/*.png").sample
	twitter.update_with_media(
		"@#{obj.user.screen_name} 友利奈緒",
		open(images),
		in_reply_to_status_id: obj.id
	)
end

on(:tweet) do |obj|
  text = obj.text
  next if text =~ /^RT/
  next if text.delete("\s") !~ /友利奈緒|ともりなお/
  Thread.new{友利奈緒(obj)}
end

command(/tomori/) do |obj|
	$rest.update_profile(name: "友利奈緒")
	$rest.update_profile_image(open("#{$dir}/data/profile/tomori.jpg"))
	obj.reply "友利奈緒だよ"
end
