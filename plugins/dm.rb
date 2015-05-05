on_event(:dm) do |obj|
	sender = obj.attrs[:sender]
	id,sn = sender[:id],sender[:screen_name]
	next unless trust?(id)
	next if sn =~ screen_name
	puts "DirectMessage -> @#{sn}:#{obj.text}"
	if obj.text =~ /^post\s+(.+)/
		post $1
		@rest.dm(id,Time.now)
	else
		@rest.dm(id, @markov.reply(obj.text))
	end
end