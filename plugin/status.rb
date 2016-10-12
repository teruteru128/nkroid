@now_revision = git_revision
@started_time = Time.now

@accounts.first.rest.update("nkroid has started up(version: #{@now_revision})")

Command.register "status" do |tweet, account|
  tweet.reply "version: #{@now_revision}\nuptime: #{strfsec(Time.now-@started_time)}"
end
