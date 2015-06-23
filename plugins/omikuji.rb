# coding: utf-8
require "yaml"

command(/omikuji|おみくじ/) do |obj|
	omikuji = YAML.load_file($dir+"/data/omikuji.yml")[0]
	text = <<-omikuji
	#{omikuji["type"].sample}
	恋愛:#{omikuji["love"].sample}
	夢:#{omikuji["dream"].sample}
	金銭:#{omikuji["money"].sample}
	学業:#{omikuji["study"].sample}
	進捗:#{omikuji["progress"].sample}
	omikuji
	obj.reply text
end