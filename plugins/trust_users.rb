require "yaml"

@following = []
@dirty = []
nkpoid = Twitter::REST::Client.new((YAML.load_file("/root/update_nkpoid/keys.yml"))[0])
myself = nkpoid.user.id

Thread.new do
	while true
		@following = nkpoid.friend_ids.to_h[:ids]
		@following << myself
		sleep 600
	end
end

def trust?(id)
	@following.include?(id) && !@dirty.include?(id)
end