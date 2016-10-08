Command.register /followback|フォロバ/ do |tweet|
  account('nkroid').rest.follow tweet.user
end

Event.hook do |event|
  if event.name == :follow && obj.target.screen_name == 'nkroid'
    account('nkroid').rest.follow obj.source
  end
end
