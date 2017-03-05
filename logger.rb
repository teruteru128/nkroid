require "logger"

$stdout.sync = true
$logger = Logger.new $stdout
$logger.datetime_format = "%Y-%m-%d %H:%M:%S"
$logger.formatter = proc do |severity, datetime, progname, message|
  case message
  when Exception
    message = "#{message.class}: #{message.message}\n#{message.backtrace.join("\n")}"
  end

  "[#{severity} #{datetime}] #{message}\n"
end

def console
  $logger
end
