require "cgi"

class Twitter::Tweet
	alias old_text text
	def text
		CGI.unescapeHTML(self.old_text)
	end
	
	def mention?
		!!self.text =~ /^(?!RT)@nkroid/
	end
end