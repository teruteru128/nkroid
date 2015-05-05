@q=Queue.new

def learn text
	text.each_line{|l|@markov.add l}
	puts TermColor.colorize("Learn -> #{text}", :yellow)
rescue => e
	puts e.message
end

Thread.new do
	while true
		while text=@q.shift
			learn text
		end
	end
end

on_event(:tweet) do |obj|
	#learn
	next unless trust? obj.user.id
	text = obj.text
	next if obj.uris?
	next if text =~ /rt|@|#|batt|http|定期|自動|playing|バッテリー|充電|ポスト|リプライ|ねくろいど/i
	next if obj.source =~ /ifttt|auto/i
	next if obj.user.screen_name =~ /mecha/i
	@q<<text
end