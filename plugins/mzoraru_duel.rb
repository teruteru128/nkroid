require "json"
require "open-uri"

on_event(:tweet) do |obj|
	text = obj.text
	if text =~ /^(?!RT)@#{screen_name}/
		next if text !~ /デュエル/
		obj.reply "accept\n#{Time.now}"
	end
end