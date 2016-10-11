require "bundler"
Bundler.require

require_relative "logger"
require_relative "model"
require_relative "helper"

Dir.glob("plugin/**/*.rb").each do |plugin|
  console.debug "loaded #{plugin}"
  require_relative plugin
end

@accounts = []
config = YAML.load_file('config/accounts.yml')
config.values.each do |key|
  @accounts << Account.new(key)
end

def account name
  @accounts.find{|account|account.screen_name == name}
end

threads = []
@accounts.each do |account|
  threads << Thread.new do
    begin
      account.stream.user replies: 'all' do |obj|
        PluginManager.handle obj, account
      end
    rescue
      console.error $!
      @accounts.first.rest.update("#{$!.class} #{$!.message}") rescue exit
      retry
    end
  end
end
threads.each{|t|t.join}
