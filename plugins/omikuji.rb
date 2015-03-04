# coding: utf-8
require "yaml"

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+(omikuji|おみくじ)/
		om = YAML.load_file(@data+"/omikuji.yml")[0]
		text = <<-omikuji
		#{om["type"].sample}
		恋愛:#{om["love"].sample}
		夢:#{om["dream"].sample}
		金銭:#{om["money"].sample}
		学業:#{om["study"].sample}
		進捗:#{om["progress"].sample}
		omikuji
		mention(obj,"#{text}\n#{Time.now}")
	end
end