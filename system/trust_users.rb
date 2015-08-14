require "yaml"
require "msgpack"

def trust?(id)
	following = MessagePack.unpack($redis.get("nkpoid_following"))
	following.include?(id)
end