# class Shiritori
#   attr_reader :last_word
#   def initialize(first_word)
#     @last_word = first_word
#   end
#   def next(word)
#     @last_word = word
#   end
#   def last_reading
#     @last_word.furigana.upper
#   end
# end
#
# class Dic < ActiveRecord::Base
#   establish_connection(
#     adapter: "sqlite3",
#     database: "db/dic.sqlite"
#   )
#   self.table_name = "dic"
# end
#
# def rand_dic
#   word = Dic.order("random()").limit(1).first.word
#   word.furigana.upper.last_reading == "ン" ? "ねくろいど" : word
# end
#
# def shiritori_by(first)
#   Dic.where("reading like ?", first+"%").order("random()").each do |res|
#     return res if (res.reading.last != ("ン" or "ー")
#   end
#   false
# end
#
# Plugin.new.command("しりとり開始") do |obj|
#   if !obj.user.using_by?(:shiritori)
#     word = rand_dic
#     obj.reply "これより、しりとりを開始します。解除する場合は「しりとり終了」とリプライを送ってください。最初は、#{word}の「#{word.furigana.upper.last_reading}」からです。"
#     obj.user.use(:shiritori)
#     $user_data[:shiritori] = Shiritori.new(word)
#   else
#     obj.reply "すでにしりとりが開始されています。"
#   end
# end
#
# Plugin.new.command("しりとり終了") do |obj|
#   if obj.user.using_by?(:shiritori)
#     obj.reply "しりとりを終了します。お疲れ様でした。"
#     obj.user.unuse(:shiritori)
#   else
#     obj.reply "しりとりが開始されていません。"
#   end
# end
#
# Plugin.new.on(:tweet) do |obj|
#   text = obj.text
#   next if text !~ /^(?!RT)@#{screen_name}\s+(.+)/
#   next if !obj.user.using_by?(:shiritori)
#   word = $1.safe
#   word_reading = word.furigana
#   last_reading = obj.user.data(:shiritori).last_reading
#   if word_reading.first != last_reading.last
#     obj.reply "#{word}(#{word_reading})は#{obj.user.data(:shiritori).last_word}(#{last_reading})に続きません。"
#   elsif word_reading.last == "ん"
#     obj.reply "最後が\'ん\'(#{word_reading})なのであなたの負けです！"
#     obj.user.unuse(:shiritori)
#   else
#     obj.user.data(:shiritori).next(word)
#     res = shiritori_by(word_reading.last.to_kana)
#     if res
#       obj.reply "\n#word(#{word_reading}) -> #{res.word}(#{res.reading})"
#       obj.user.data(:shiritori).next(res.word)
#     else
#       obj.reply "あなたの勝ちです。おめでとうございます。"
#       obj.user.unuse(:shiritori)
#     end
#   end
# end
