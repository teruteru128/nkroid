puts "init..."

require "bundler"
require "active_record"
require "yaml"
Bundler.require
Dotenv.load

$console = Logger.new($stdout)
$console.progname = ENV['APPNAME']
$console.datetime_format = "%Y-%m-%d %H:%M:%S"
$console.formatter = proc{|severity, datetime, progname, message|
	"[#{severity} #{datetime}] #{message}\n"}
def console
  $console end

Dir.glob("./core/*.rb").sort.each do |file|
  console.info "Load core/#{File.basename file}"
  require file end
Dir.glob("./plugin/*.rb").sort.each do |file|
  console.info "Load plugin/#{File.basename file}"
  require file end

Bot.new(accounts).run
