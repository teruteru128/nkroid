localdb.execute <<-SQL
create table if not exists name(
  id int primary key,
  name text,
  screen_name text
)
SQL

Command.register "update_name" do |tweet, account|
  message = if name = tweet.args[1]
    account("nkroid").rest.update_profile(name: name)
    localdb.execute "insert into name (name, screen_name) values (?, ?)", [name, tweet.user.screen_name]
    sanitize_reply "#{name}になりました。"
  else
    "名前が指定されていません。"
  end

  tweet.reply message, account.rest
end

Command.register "random_update_name" do |tweet, account|
  result = localdb.execute("select * from name order by random() limit 1")[0] rescue nil
  message = if result
    name, screen_name = *result[1, 2]
    account("nkroid").rest.update_profile(name: name)
    "@#{screen_name}さんに付けられた#{name}に名前を変更しました。"
  else
    "過去に名前が付けられていません。><"
  end
  tweet.reply message, account.rest
end
