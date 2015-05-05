# coding: utf-8
require "open-uri"

def copy(type,id,obj)
	if @profile_locked
		mention(obj,"プロフィールは現在#{@locker}によってロックされています。\n#{time}")
		return
	end
	if id =~ /nk(p|q|v)oid/
		@rest.update("@#{obj.user.screen_name} 作者をコピーするな殺すぞ\n#{Time.now.strftime("%x %H:%M:%S")}",:in_reply_to_status_id => obj.id)
		return
	elsif !(trust?(obj.user.id))
		@rest.update("@#{obj.user.screen_name} 現在、コピー機能は特定の方のみしか利用出来ません。\n#{Time.now.strftime("%x %H:%M:%S")}",:in_reply_to_status_id => obj.id)
		return
	end
	copy_name = id.gsub("@","")
	raise "Error!(User not found.)" if !@rest.user?(copy_name)
	user = @rest.user id
	icon = user.profile_image_uri.to_s.gsub("_normal","")
	banner = user.profile_banner_uri.to_s.gsub("_normal","")
	time = Time.now.strftime("%x %H:%M:%S")
	case type
	when "name"
		@rest.update_profile(:name => user.name)
		text = "#{user.screen_name}(#{user.name})さんの名前をコピーしました！"
	when "icon"
		@rest.update_profile_image(open icon)
		text = "#{user.screen_name}(#{user.name})さんのアイコンをコピーしました！"
	when "all"
		@rest.update_profile(:name => user.name)
		@rest.update_profile_image(open icon)
		@rest.update_profile_banner(open banner)
		text = "#{user.screen_name}(#{user.name})さんのプロフィールをコピーしました！\n元に戻す際は私に向かって\"デフォルト\"とメンションを送ってください。"
	else
		text = "System -> Format error!><"
	end
	@rest.update("@#{obj.user.screen_name} #{text}",:in_reply_to_status_id => obj.id)
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+copy_(.+)\s+(.+)$/
		type,id = $1,$2
		Thread.new{copy(type, id, obj)}
	end
end
