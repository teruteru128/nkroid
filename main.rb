#!/usr/bin/ruby
# coding: utf-8
$dir = File.expand_path(".")
print "init..."
$init_thread = Thread.new{loop{sleep 0.4;$stderr.print "."}}

require "twitter"
require "pg"
require "yaml"
require "logger"
require "timeout"
require "redis"
require "./accounts"
$init_thread.kill;puts

$console = Logger.new($stdout)
$console.progname = "nkroid"
$console.datetime_format = "%Y-%m-%d %H:%M:%S"
$console.formatter = proc{|severity, datetime, progname, message|
	"[#{severity} #{datetime}] #{message}\n"
}
$accounts = AccountManager.new
$keys = YAML.load_file("./data/keys.yml")
$rest = Twitter::REST::Client.new($keys[0]);$accounts<<$rest #メインアカウント
$keys[1..-2].each{|key|$accounts<<Twitter::REST::Client.new(key)} #規制用アカウント
$stream = Twitter::Streaming::Client.new($keys[0])
$db = PG::connect(YAML.load_file("./data/database.yml")["production"])
$redis = Redis.new

cores = Dir.glob("./system/*.rb").sort
cores.each do |core|
	core =~ /system\/(.+\.rb)$/
	$console.info "Load #{$1}"
	eval(File.read(core)) end
plugins = Dir.glob("./plugins/*.rb").sort
plugins.each do |plugin|
	plugin =~ /plugins\/(.+\.rb)$/
	$console.info "Load #{$1}"
	eval(File.read(plugin)) end

def main
	$stream.user(replies:"all") do |obj|
		extract(obj)
	end
rescue
	$console.error $!
	main
end

main()
