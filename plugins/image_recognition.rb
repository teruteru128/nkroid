require 'net/http'
require 'uri'
require "open-uri"
require "json"
require "nokogiri"

def http_request(method, uri, query_hash={})
	query = query_hash.map{|k, v| "#{k}=#{v}"}.join('&')
	query_escaped = URI.escape(query)
	uri_parsed = URI.parse(uri)
	http = Net::HTTP.new(uri_parsed.host)
	case method.downcase!
	when 'get'
		return http.get(uri_parsed.path + '?' + query_escaped).body
	when 'post'
		return http.post(uri_parsed.path, query_escaped).body
	end
end

def image_recognition(image_url)
	key = "594e6f52645745416a7938587877327a53574d354a35506668416668465a727763336246675033655a6f33"
	uri = URI.parse("https://api.apigw.smt.docomo.ne.jp/imageRecognition/v1/recognize?APIKEY=#{key}&recog=product-all&numOfCandidates=1")
	apiurl="/imageRecognition/v1/recognize?APIKEY=#{key}&recog=product-all&numOfCandidates=1"
	req=Net::HTTP::Post.new(apiurl,initheader={'Content-Type'=>"application/octet-stream"})
	req.body = File.binread(open(image_url))
	https = Net::HTTP.new(uri.host,uri.port)
	https.use_ssl = true
	res = https.start{|http|http.request(req)}
	result = JSON.parse(res.body)
	raise "Not applicable.(id->#{result["recognitionId"]})" if !result["candidates"]
	result = result["candidates"][0]
	"それは#{result["detail"]["itemName"]}ではありませんか？\n#{result["imageUrl"]}"
rescue => e
	return "#{e.class}\n#{e.message}"
end

def sim_image(image_url)
	res = http_request(
		"POST",
		"http://www.ascii2d.net/imagesearch/search",
		{uri: image_url+":orig"}
	)
	url = Nokogiri::HTML.parse(res).css("a")[0]["href"]
	doc = Nokogiri::HTML.parse(open(url).read)
	{
		thumb: "http://www.ascii2d.net"+doc.xpath("//div[@class='image']")[1].children.attribute('src').value,
		title: doc.xpath("//div[@class='detail']/a")[0].children.text,
		url: doc.xpath("//div[@class='detail']/a")[0].attributes["href"].value
	}
end

on_event(:tweet) do |obj|
	if obj.text =~ /これ(なに|何)/
		next if obj.text =~ /rt/i
		if obj.media?
			Thread.new do
				url = obj.media[0].media_uri.to_s
				text = image_recognition(url)
				twitter.update("@#{obj.user.screen_name} #{text}",:in_reply_to_status_id => obj.id)
			end
		else
			obj.reply "画像を添付してください。\n#{time}"
		end
	end
end

on_event(:tweet) do |obj|
	if obj.text =~ /似てるの(なに|何)/
		next if obj.text =~ /rt/i
		if obj.media?
			@rest.fav obj
			Thread.new do
				hash = sim_image(obj.media[0].media_uri.to_s)
				twitter.update(
					"@#{obj.user.screen_name} 「#{hash[:title]}」(#{hash[:url]})が似ているかもしれません。",
					:in_reply_to_status_id => obj.id
				)
			end
		else
			obj.reply "画像を添付してください。\n#{time}"
		end
	end
end