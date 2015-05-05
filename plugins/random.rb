# coding: utf-8

def rand_name
	@db.execute("SELECT * FROM name ORDER BY RANDOM() LIMIT 1")[0]
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@(#{screen_name})\s+(?:randum|random|ランダム|らんだむ)/i
		if @profile_locked
			mention(obj,"プロフィールは現在#{@locker}によってロックされています。\n#{time}")
			next
		end
		row = rand_name
		sn,name,time = *row
		text = "@#{sn}さんによって#{time}につけられた「#{name}」に改名しました"
		@rest.update_profile(name: name)
		@rest.update(".@#{obj.user.screen_name} #{text}")
	end
end
