command(/follow_(me|back)|フォロバ/) do |obj|
	$accounts.accounts.each{|t|t.follow obj.user}
end

on(:event) do |obj|
	case obj.name
	when :follow
		next if obj.target.screen_name !~ screen_name
		user = obj.source
		next if user.lang != "ja"
		$accounts.accounts.each{|t|t.follow user}
	end
end
