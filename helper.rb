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
