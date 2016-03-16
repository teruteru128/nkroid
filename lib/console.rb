require "logger"

module Bot
  @console = Logger.new $stdout
  @console.datetime_format = "%Y-%m-%d %H:%M:%S"
  @console.progname = "nkroid"
  @console.formatter = proc{|severity, datetime, progname, message|
    "[#{severity}] #{message}\n"
  }

  def self.console
    @console
  end
end
