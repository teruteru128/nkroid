require "open-uri"

on_event(:tweet) do |obj|
	if obj.text =~ /^(?!RT)@(#{screen_name})\s+114514/
		@dirty << obj.user.id
		mention(obj,"イキスギィ！。\n#{Time.now}")
	end
end
