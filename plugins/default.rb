# coding: utf-8

def default(obj)
	Thread.new do
		$rest.fav obj
		$rest.update_profile(:name => "ねくろいど")
		icon,header = *(["icon.png","header.png"].map{|p|"#{$dir}/data/profile/#{p}"})
		open(icon){|file|$rest.update_profile_image(file)}
		sleep 1
		open(header){|file|$rest.update_profile_banner(file)}
		obj.reply "プロフィールをデフォルトに戻しました"
	end
rescue => e
	obj.reply e.message
	$console.error e
end

command(/default|デフォルト|でふぉ|でふぉると/){|obj|default(obj)}