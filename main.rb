#!/usr/bin/ruby
# coding: utf-8
print "System -> init..."
$init_thread = Thread.new{loop{sleep 0.4;$stderr.print "."}}

require "yaml"
require "./account.rb"
$init_thread.kill
puts

Thread.new{loop{sleep 60;system("echo 3 > /proc/sys/vm/drop_caches")}}

def main
	$init_completed = false
	keys = YAML.load_file("./keys.yml")
	cores = Dir.glob(File.expand_path("../system/*.rb", __FILE__))
	cores.each do |core|
		core =~ /system\/(.+\.rb)$/
		$stderr.puts "System -> Load #{$1}"
		eval(File.read(core))
	end
	puts "System -> initialized system!!"
	account = Account.new(keys)
	plugins = Dir.glob(File.expand_path("../plugins/*.rb", __FILE__))
	plugins.each do |plugin|
		plugin =~ /plugins\/(.+\.rb)$/
		$stderr.puts "System -> Load #{$1}"
		account.instance_eval(File.read(plugin))
	end
	puts "System -> Load complete!"
	$init_completed = true
	account.start
rescue => e
	if $init_completed
		t=Thread.new{account.start}
		t.join
	else
		puts(e.class,e.message)
	end
end

main()