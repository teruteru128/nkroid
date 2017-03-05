@now_revision = git_revision
@started_time = Time.now

Command.register "status" do |tweet, account|
  tweet.reply "version: #{@now_revision}\nuptime: #{strfsec(Time.now-@started_time)}", account.rest
end
