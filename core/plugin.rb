class Plugin
  @@events = {}
  @@commands = {}
  def initialize(params={})
    @params = params
  end

  def on(type, &blk)
    @@events[type] ||= []
    @@events[type] << {proc: blk, params: @params}
  end

  def command(cmd, opt={}, &blk)
    @@commands[cmd] = {proc: blk, params: @params}
  end

  class << self
    def events
      @@events end

    def commands
      @@commands end
  end
end

def event_callback(event, obj)
  return if !Plugin.events[event]
  Plugin.events[event].each{|h|h[:proc].call obj}
end

def command_callback(status)
  Plugin.commands.keys.each do |cmd|
    if status.text =~ /^(?!RT)@#{screen_name}\s+#{cmd}/
      status.args = [$1,$2,$3,$4,$5]
      Plugin.commands[cmd][:proc].call status
    end
  end
end

class Twitter::Tweet
  def cmd?
    text = self.text
    !!Plugin.commands.keys.find{|cmd|text =~ /^(?!RT)@#{screen_name}\s+#{cmd}/}
  end
end
