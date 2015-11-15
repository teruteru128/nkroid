require "nkf"
$smaller_table = [['ぁ', 'あ'],  ['ぃ', 'い'],  ['ぅ', 'う'],  ['ぇ', 'え'],  ['ぉ', 'お'],  ['っ', 'つ'],  ['ゃ', 'や'],  ['ゅ', 'ゆ'],  ['ょ', 'よ'],  ['ゎ', 'わ'],  ['ァ', 'ア'],  ['ィ', 'イ'],  ['ゥ', 'ウ'],  ['ェ', 'エ'],  ['ォ', 'オ'],  ['ヵ', 'カ'],  ['ヶ', 'ケ'],  ['ッ', 'ツ'],  ['ャ', 'ヤ'],  ['ュ', 'ユ'],  ['ョ', 'ヨ'],  ['ヮ', 'ワ']]

class String
  def to_kana
    NKF.nkf("--katakana -w",self)
  end
  def to_hira
    NKF.nkf("--hiragana -w",self)
  end
  def upper
    $smaller_table.each do |n|
      self.gsub!(/#{n[0]}$/,n[1])
    end
    self
  end
  def first
    self[0]
  end
  def last
    self[-1]
  end
  def last_reading
    index = -1
    while true
      self[index] == "ー" ? index -= 1 : break
    end
    self[index]
  end
  def safe
    self.gsub("@","@\u200b")
  end
end
