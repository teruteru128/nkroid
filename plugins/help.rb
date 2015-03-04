# coding: utf-8

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+help/
		helps = YAML.load_file(@data+"/help.yml")
		helps.each do |help|
			mention(obj,help)
		end
	end
end
