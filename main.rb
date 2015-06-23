#!/usr/bin/ruby
# coding: utf-8
$dir = File.expand_path(".")
print "System -> init..."
$init_thread = Thread.new{loop{sleep 0.4;$stderr.print "."}}

#ねくろいどはご覧のスポンサーでお送りいたします
require "twitter"
require "pg"
require "yaml"
require "./accounts"
require "./log"
$init_thread.kill;puts

#変数定義
#桐間紗路ちゃんのおパンツドリップコーヒー
$accounts = AccountManager.new
$log = Log.new
$keys = YAML.load_file($dir+"/data/keys.yml")
$rest = Twitter::REST::Client.new($keys[0]);$accounts<<$rest #メインアカウント
$keys[1..-2].each{|key|$accounts<<Twitter::REST::Client.new(key)} #規制用アカウント
$stream = Twitter::Streaming::Client.new($keys[0])
$db = PG::connect(YAML.load_file($dir+"/data/dbconfig.yml")["connection"])
$threads = []

#外部読み込み処理開始
cores = Dir.glob($dir+"/system/*.rb").sort
cores.each do |core|
	core =~ /system\/(.+\.rb)$/
	$log.send "Load #{$1}"
	eval(File.read(core)) end
plugins = Dir.glob($dir+"/plugins/*.rb").sort
plugins.each do |plugin|
	plugin =~ /plugins\/(.+\.rb)$/
	$log.send "Load #{$1}"
	eval(File.read(plugin)) end

$markov = Markov.new

def main
	$stream.user(:replies => "all") do |obj|
		if $threads.length > 19
			$threads[0].kill 
			$threads.slice! 0
		end
		$threads << Thread.new{extract_obj obj}
	end
rescue => e
	$log.send_error "#{e.class} #{e.message}"
	main
end

main()