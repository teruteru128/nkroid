require "bundler"
Bundler.require

require_relative "logger"
require_relative "helper"

Dir.glob("plugin/**/*.rb").each do |plugin|
  require_relative plugin
  console.debug "loaded #{plugin}"
end

Tweet.hook do |tweet|
  puts tweet.text
end

Account.load_yaml("config/accounts.yml")
Account.all.each do |account|
  account.thread = Thread.new{account.start_stream}
end
Account.threads.each{|t|t.join}
