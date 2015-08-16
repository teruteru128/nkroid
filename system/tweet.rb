require "cgi"

class Twitter::Tweet
	attr_accessor :args
	alias old_text text
	def text
		CGI.unescapeHTML(self.old_text)
	end
	
	def mention?
		!!self.text =~ /^(?!RT)@nkroid/
	end

	def reply(text,opt=true)
		message = "@#{self.user.screen_name} #{text}"
		if opt || message.length <= 140
			twitter.update(message,in_reply_to_status_id: self.id)
		else
			twitter.update("@#{self.user.screen_name} 文字数超過の為DMで結果を送信しました",in_reply_to_status_id: self.id)
			text.to_s.scan(/.{1,#{9900}}/).each do |mes|
				$rest.dm(self.user.screen_name,mes)
			end
		end
	rescue Twitter::Error
		$accounts.fallback
		post $!.class
		retry
	rescue
		$console.error $!
		post $!
	end
end