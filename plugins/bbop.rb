require "levenshtein"

B = "バビブベボ".chars.freeze
def b
	B.sample
end
P = "パピプペポ".chars.freeze
def p
	P.sample
end
D = "ダヂヅデド".chars.freeze
def d
	D.sample
end
R = "ラリルレロ".chars.freeze
def r
	R.sample
end
FIGURE = "☆♪＊".chars.freeze
def figure
	FIGURE.sample
end
ER = "ー～＝".chars.freeze
def er
	ER.sample
end

BBOP = "ビビッドレッド・オペレーション"

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+bbop/
		var = rand(49)
		bbop =
			case var
			when 0
				BBOP
			when 1
				BBOP.reverse
			else
				"#{b}#{b}ッ#{d}#{r}ッ#{d}#{figure}オ#{p}#{r}#{er}ション"
			end
		per = (1 - Levenshtein.normalized_distance(bbop, BBOP)) * 100
		text = bbop + "(#{per}%)"
		mention(obj,text)
	end
end
