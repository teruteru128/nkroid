require "cgi"

class Twitter::Tweet
  attr_accessor :args
  alias :__text__ :text
  def text
    CGI.unescapeHTML self.__text__
  end

  def reply(text)
    return if self.source.include? ENV['CLIENT_NAME']
    message = "@#{self.user.screen_name} #{text}"
    twitter.update(message, in_reply_to_status_id: self.id)
  end
end

def post text
  twitter.update text end
