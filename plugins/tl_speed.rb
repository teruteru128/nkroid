$on_time = Time.now
$tweetcount = 0
on_event(:tweet) do |obj|
	$tweetcount += 1
end

command("status") do |obj|
	npm = ($tweetcount / (obj.created_at - $on_time)) * 60.0
	obj.reply "現在のタイムラインの流速は#{npm.round(3)}tweet/分です"
end