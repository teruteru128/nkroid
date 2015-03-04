foods = ["焼肉","寿司","ラーメン","ピザ","ステーキ","飯テロ"]

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT).*((おなか|お腹)(すいた|空いた)|空腹|腹減|はらへ)/
		Thread.new do
			3.times do
				food = foods.sample
				tweet_pic(obj,"@#{obj.user.screen_name} #{food}",food)
				sleep 1
			end
		end
	end
end