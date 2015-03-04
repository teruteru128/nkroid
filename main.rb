#!/usr/bin/ruby
# coding: utf-8
puts "System -> init..."

require "yaml"
require "./account.rb"

keys = YAML.load_file("./keys.yml")
main = Thread.new do
	cores = Dir.glob(File.expand_path("../system/*.rb", __FILE__))
	cores.each{|core|eval(File.read(core))}
	puts "System -> initialized system!!"
	account = Account.new(keys)
	plugins = Dir.glob(File.expand_path("../plugins/*.rb", __FILE__))
	plugins.each do |plugin|
		plugin =~ /plugins\/(.+\.rb)$/
		puts "System -> Load #{$1}"
		account.instance_eval(File.read(plugin))
	end
	puts "System -> Load complete!"
	account.start
end

main.join