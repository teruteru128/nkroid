on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s(?:follow_me|フォロバ)/
		obj.text =~ screen_name
		rest = rest_by($1)
		rest.follow obj.user
	end
end

on_event(:event) do |obj|
	case obj.name
	when :follow
		next if obj.target.screen_name !~ screen_name
		user = obj.source
		next if user.lang != "ja"
		rest_by(obj.target.screen_name).follow(user)
	end
end