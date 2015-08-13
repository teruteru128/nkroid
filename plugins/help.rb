# coding: utf-8

command("help") do |obj|
	helps = YAML.load_file($dir+"/data/help.yml")
	helps.each do |help|
		obj.reply help
	end
end