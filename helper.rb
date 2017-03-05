require "time"

def account screen_name
  Account.find screen_name
end

def decodeSnowflake id
  Time.at(((id >> 22) + 1288834974657) / 1000.0)
end

def localdb
  SQLite3::Database.new "data/nkroid.sqlite3"
end

def sanitize_reply text
  text.gsub("@", "@\u200b")
end

def git_revision
  `git rev-parse HEAD`[0, 8]
end

def strfsec sec
  day, sec_r = sec.divmod(86400)
  (Time.parse("1/1") + sec_r).strftime("#{day}日%H時間%M分%S秒")
end
