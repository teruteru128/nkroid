on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+introduce/
		twitter.update("#{rand_keyphrase}(@#{obj.user.screen_name})",:in_reply_to_status_id => obj.id)
	end
end