@now_revision = git_revision
@started_time = Time.now

Init.hook do |list, account|
  account("nkroid").rest.update("nkroid has started up(version: #{@now_revision})")
end

Command.register "status" do |tweet, account|
  tweet.reply "version: #{@now_revision}\nuptime: #{strfsec(Time.now-@started_time)}", account.rest
end
