require "net/http"
require "uri"

def register_recotw(id,name)
	uri = URI.parse("http://api.recotw.black/1/tweet/record_tweet")
	http = Net::HTTP.start(uri.host, uri.port)
	header = {"user-agent" => "Ruby/nkroid"}
	body = "id=#{id}&via=#{name}"
	response = http.post(uri.path, body, header)
	JSON.parse response.body
end

def obj_by source
	twitter.status source
rescue
	false
end

def recotw(obj)
	obj.uris.each do |uri|
		target = obj_by uri.expanded_url.to_s
		next if !target
		res = register_recotw(target.id, obj.user.screen_name)
		if res["errors"]
			text = "Error:"+res["errors"][0]["message"]+"\n#{Time.now}"
		else
			tweet = res["content"]
			tweet = tweet.size > 20 ? tweet[0,19]+"..." : tweet
			text = "@#{res["target_sn"]}さんの黒歴史(#{tweet})をRecotwしました。\nhttps://recotw.chitoku.jp/?id=#{res["tweet_id"]}"
		end
		obj.reply text
	end
rescue
	obj.reply $!.message
end

Plugin.new.on(:tweet) do |obj|
	next if obj.text !~ /@#{screen_name}/
	next unless obj.uris?
	next if obj.text=~/rt/i
	next if obj.user.screen_name =~ /mecha/i
	recotw(obj)
end
