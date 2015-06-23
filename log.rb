class Log
	@@file_name = File.expand_path("../log/#{Time.now.strftime("%Y%m%d%H%M%S")}.log", __FILE__)

	def initialize
		write "#{Time.now} System -> Logger initialized"
	end

	def write str
		File.open(@@file_name,"a"){|f|f.puts str}
	end

	def send str
		write "#{Time.now} System -> #{str}"
		puts "System -> #{str}"
	end

	def send_error str
		write "#{Time.now} Error -> #{str}"
		$stderr.puts "Error -> #{str}"
	end
end