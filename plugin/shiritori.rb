class Shiritori
  attr_reader :history
  def initialize
    @history = []

    str = db.execute("select * from dic where not reading like '%ン' order by random() limit 1")[0][0]
    @history << Word.new(str, :cpu)
  end

  def user word
    @history << word
    cpu_word = next_word
    @history << cpu_word
  end

  def last
    @history[-1]
  end

  def duplicate? str
    @history.any?{|word|word.letter == str}
  end

  def next_word
    str = db.execute("select * from dic where reading like '#{self.last.furikana}%' order by random() limit 1")[0][0]
    Word.new(str, :cpu)
  rescue
    return nil
  end

  def db
    SQLite3::Database.new 'data/shiritori.sqlite3'
  end
  private :next_word, :db

  class Word
    @@cache = {}

    attr_reader :letter
    def initialize letter, type
      raise TypeError if not letter.kind_of?(String)
      @letter = letter
      @type = type
    end

    def cpu?
      @type == :cpu
    end
    def player?
      @type == :player
    end

    def furigana
      return @@cache[@letter] if @@cache[@letter]

      appid = "dj0zaiZpPUF4bHBKc29UTDNuMyZzPWNvbnN1bWVyc2VjcmV0Jng9NDk-"
      endpoint = "http://jlp.yahooapis.jp/FuriganaService/V1/furigana?appid=#{appid}&sentence=#{URI.encode(@letter)}"
      doc = REXML::Document.new(open(endpoint))
      furigana = doc.elements.collect("ResultSet/Result/WordList/Word/Furigana"){|el|el.text}.join
      @@cache[@letter] = furigana
      return furigana
    end

    def furikana
      furigana.tr('ぁ-ん','ァ-ン')
    end
  end
end

Command.register "しりとり開始" do |tweet, account|
  user = tweet.user
  if user.locked?
    if user.locker.kind_of?(Shiritori)
      tweet.reply "すでにしりとりが開始されています", account.rest
    end
  else
    shiritori = Shiritori.new
    user.locker = shiritori
    word = shiritori.last
    tweet.reply "しりとり開始。最初は#{word.letter}(#{word.furigana[-1]})です。", account.rest
  end
end

Command.register "しりとり終了" do |tweet, account|
  user = tweet.user
  if user.locked?
    if user.locker.kind_of?(Shiritori)
      user.unlock
      tweet.reply "しりとりを終了します。", account.rest
    end
  else
    tweet.reply "しりとりが開始されていません。", account.rest
  end
end

Tweet.hook do |tweet, account|
  next if tweet.text !~ /^@nkroid\s+(.+)/
  next if Command.check(tweet)
  user = tweet.user
  if user.locker.kind_of?(Shiritori)
    shiritori = user.locker
    next_word = Shiritori::Word.new($1, :player)
    last_word = shiritori.last
    if next_word.furigana[0] != last_word.furigana[-1]
      message = "しりとりが続いていません。次は#{last_word.letter}(#{last_word.furigana})です。"
    elsif next_word.furigana[-1] == "ん"
      message = "#{next_word.furigana[0..-2]}「ん」。あなたの負けです。しりとりを終了します。"
      user.unlock
    elsif shiritori.duplicate? $1
      message = "#{$1}はすでに使われています。"
    else
      shiritori.user next_word
      if shiritori.last.nil?
        message = "負けました…"
        user.unlock
      else
        message = "次は#{shiritori.last.letter}の#{shiritori.last.furigana[-1]}です。"
      end
    end
    tweet.reply message, account.rest
  end
end
