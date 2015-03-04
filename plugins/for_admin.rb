on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+stop/
		if obj.user.screen_name == "nkpoid"
			post("管理者の命令により強制終了します。\n#{Time.now}")
			exit
		else
			mention(obj,"You don't have a Permission.(@nkpoid is the only administrator now.)")
		end
	when /^(?!RT)@#{screen_name}\s+block\s+(.+)/
		user = $1
		if !(trust?(obj.user.id))
			mention(obj,"You don't have a Permission.")
		elsif !(@rest.user? user)
			mention(obj,"ユーザが存在しません。")
		elsif @rest.block? user
			mention(obj,"すでにブロック済みです。")
		else
			@rest.block user
			post(".@#{obj.user.screen_name} #{user}さんをブロックしました。")
		end
	end
end