@ejacer = Hash.new

on_event(:tweet) do |obj|
	if obj.text =~ /(シコ|オナ)る/
		next if obj.text =~ /rt/i
		t = obj.created_at
		mention(obj,"#{obj.user.name}、オナニー開始！\n#{t}")
		@ejacer[obj.user.id] = [t,obj.id]
	end
end

on_event(:tweet) do |obj|
	next if obj.text =~ /rt/i
	if @ejacer.include?(obj.user.id)
		hash = @ejacer[obj.user.id]
		t,id = *hash
		next if obj.id == id
		dist = Time.now-t
		so_low = dist > 60 ? "" : "\nや〜い、早漏！！！"
		mention(obj,"#{obj.user.name}、オナニー終了！\n開始:#{t}\n終了:#{Time.now}\n#{dist}秒"+so_low)
		@ejacer.delete obj.user.id
	end
end