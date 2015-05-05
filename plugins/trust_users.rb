require "yaml"

@following = []
nkpoid = Twitter::REST::Client.new((YAML.load_file(@data+"/poid.yml"))[0])
@following = nkpoid.friend_ids.to_h[:ids]
@following << nkpoid.user.id

def trust?(id)
	@following.include?(id)
end