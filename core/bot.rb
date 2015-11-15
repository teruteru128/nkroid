class Bot
  attr_reader :accounts
  def initialize(accounts)
    @accounts = accounts
  end

  def run
    @accounts.stream.user(replies: "all") do |obj|
      extract obj
    end
  rescue
    console.error $!
    console.error $!.backtrace
    retry
  end

  def extract(obj)
    case obj
    when Twitter::Tweet
      event_callback(:tweet, obj)
      command_callback(obj)
    when Twitter::Streaming::Event
      event_callback(:event, obj)
    when Twitter::Streaming::FriendList
      event_callback(:friendlist, obj)
    when Twitter::Streaming::DeletedTweet
      event_callback(:delete, obj)
    when Twitter::DirectMessage
      event_callback(:dm, obj)
    end
  end
end

def screen_name
  /nkroid.*/ end
