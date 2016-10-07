Plugin.new :command, str: [/followback|フォロバ/] do |tweet|
  account('nkroid').rest.follow tweet.user
end

Plugin.new :event do |event|
  next if event.name != :follow
  next if obj.target.screen_name != 'nkroid'
  account('nkroid').rest.follow obj.source
end
