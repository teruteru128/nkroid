require "cgi"

class Twitter::Tweet
	alias old_text text
	def text
		CGI.unescapeHTML(self.old_text)
	end
	
	def mention?
		!!self.text =~ /^(?!RT)@nkroid/
	end

	def reply(text)
		text.scan(/.{1,#{120}}/m).each do |s|
			twitter.update("@#{self.user.screen_name} #{s}",:in_reply_to_status_id => self.id)
		end
	rescue Twitter::Error
		$accounts.fallback
		$console.info "account changed(@#{$accounts.cursor.user.screen_name})"
		retry
	end
end