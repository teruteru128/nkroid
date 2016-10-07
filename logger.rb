require "logger"

$stdout.sync = true
@console = Logger.new $stdout
@console.datetime_format = "%Y-%m-%d %H:%M:%S"
@console.formatter = proc do |severity, datetime, progname, message|
  case message
  when Exception
    message = "#{message.class}: #{message.message}\n#{message.backtrace.join("\n")}"
  end
  message = message.is_a?(String) ? message : message.inspect
  "[#{severity}] #{message}\n"
end
