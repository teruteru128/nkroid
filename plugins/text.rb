# coding: utf-8

def mosaic str
	ary = []
	str.split(//).each do |s|
		ary << (rand(3) == 0 ? "*" : s)
	end
	ary.join ""
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+text\s+(.+)/m
		text = $1.gsub(/@|＠/,"@\u200b")
		if trust?(obj.user.id)
			twitter.update(text+"\n"+mosaic(obj.user.screen_name),:in_reply_to_status_id => obj.id)
		else
			mention(obj,"現在、textは特定の方しかご利用になれません。")
		end
	end
end
