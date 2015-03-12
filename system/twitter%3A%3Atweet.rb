require "cgi"

class << Twitter::Tweet
	def text
		CGI.unescapeHTML @text
	end
end