#!/usr/bin/ruby
# coding: utf-8
$dir = File.expand_path(".")
require "twitter"
require "yaml"

$accounts = []
$keys = YAML.load_file($dir+"/data/keys.yml")
$keys.each{|key|$accounts<<Twitter::REST::Client.new(key)}

$accounts.each do |rest|
	begin
		selfname = rest.user.screen_name
		puts selfname
		follower = rest.follower_ids.to_h[:ids]
		following = rest.friend_ids.to_h[:ids]
		list = following - follower
		puts list.size
		list.each{|n|rest.unfollow n;print n}
		puts
	rescue
		next
	end
end