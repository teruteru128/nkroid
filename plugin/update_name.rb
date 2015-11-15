class Name < ActiveRecord::Base
end

def update_name(obj,name)
  accounts.main.update_profile(name: name)
  obj.reply "#{name.gsub("@","@\u200b")}になりました。"
  Name.create(name: name, screen_name: obj.user.screen_name)
end

Plugin.new.on(:tweet) do |obj|
  next if obj.text !~ /^(?!RT)(.+)\(@#{screen_name}\)/
  update_name(obj, $1)
end
Plugin.new.command(/(?:update_name|rename)\s(.+)/){|obj|update_name(obj, obj.args[0])}
