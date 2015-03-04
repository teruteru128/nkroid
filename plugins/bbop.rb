require "levenshtein"

def b
	"バビブベボ".split(//).sample
end
def p
	"パピプペポ".split(//).sample
end
def d
	"ダヂヅデド".split(//).sample
end
def r
	"ラリルレロ".split(//).sample
end
def figure
	"☆♪＊".split(//).sample
end
def er
	"ー～＝".split(//).sample
end

on_event(:tweet) do |obj|
	case obj.text
	when /^(?!RT)@#{screen_name}\s+bbop/
		var = rand(49)
		case var
		when 0
			bbop = "ビビッドレッド・オペレーション"
		when 1
			bbop = "ビビッドレッド・オペレーション".split(//).reverse.join
		else
			bbop = "#{b}#{b}ッ#{d}#{r}ッ#{d}#{figure}オ#{p}#{r}#{er}ション"
		end
		per = (1 - Levenshtein.normalized_distance(bbop,"ビビッドレッド・オペレーション")) * 100
		text = bbop + "(#{per}%)"
		mention(obj,text)
	end
end
