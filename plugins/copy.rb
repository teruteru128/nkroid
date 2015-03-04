# coding: utf-8
require "open-uri"

def copy(type,id,obj)
	if id =~ /nk(p|q|v)oid/
		@rest.update("@#{obj.user.screen_name} 作者をコピーするな殺すぞ\n#{Time.now.strftime("%x %H:%M:%S")}",:in_reply_to_status_id => obj.id)
		return
	elsif !(trust?(obj.user.id))
		@rest.update("@#{obj.user.screen_name} 現在、コピー機能は特定の方のみしか利用出来ません。\n#{Time.now.strftime("%x %H:%M:%S")}",:in_reply_to_status_id => obj.id)
		return
	end
	copy_name = id.gsub("@","")
	unless @rest.user?(copy_name)
		text = "Error!(User not found.)"
	else
		@rest.fav(obj)
		h = get_user(id)
		time = Time.now.strftime("%x %H:%M:%S")
		case type
		when "name"
			@rest.update_profile(:name => h[:name])
			text = "#{copy_name}(#{h[:name]})さんの名前をコピーしました！"
		when "icon"
			OpenURI.open_uri(h[:icon]) do|file|
				@rest.update_profile_image(file)
			end
			text = "#{copy_name}(#{h[:name]})さんのアイコンをコピーしました！"
		when "all"
			@rest.update_profile(:name => h[:name], :url => h[:url], :location => h[:location])
			OpenURI.open_uri(h[:icon]) do|file|
				@rest.update_profile_image(file)
			end
			OpenURI.open_uri(h[:head]) do|file|
				@rest.update_profile_banner(file)
			end
			text = "#{h[:sn]}(#{h[:name]})さんのプロフィールをコピーしました！\n元に戻す際は私に向かって\"デフォルト\"とメンションを送ってください。"
		else
			text = "System -> Format error!><"
		end
	end
	@rest.update("@#{obj.user.screen_name} #{text}",:in_reply_to_status_id => obj.id)
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+copy_(.+)\s+(.+)$/
		type,id = $1,$2
		Thread.new{copy(type, id, obj)}
		puts "System -> copy #{$2} type: #{$1}"
	end
end
