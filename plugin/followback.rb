Plugin.new.command(/follow_?(me|back)|フォロバ/) do |obj|
	accounts.list.each{|t|t.follow obj.user}
end

Plugin.new.on(:event) do |obj|
	case obj.name
	when :follow
		next if obj.target.screen_name !~ screen_name
		user = obj.source
		next if user.lang != "ja"
		accounts.list.each{|t|t.follow user}
	end
end
