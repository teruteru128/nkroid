require "yaml"

=begin
@following = []
nkpoid = Twitter::REST::Client.new((YAML.load_file($dir+"/data/poid.yml"))[0])
@following = nkpoid.friend_ids.to_h[:ids]
@following << nkpoid.user.id
=end
def trust?(id)
	true#@following.include?(id)
end