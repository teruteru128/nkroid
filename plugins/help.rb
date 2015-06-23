# coding: utf-8

command("help") do |obj|
	helps = YAML.load_file($dir+"/data/help.yml")
	helps.each do |help|
		mention(obj,help)
	end
end