require "timeout"

class Sandbox
	def self.eval(str,safe=3)
		Timeout::timeout 1 do
			return Thread.new{$SAFE=safe;instance_eval(str)}.value
		end
	rescue Exception
		"#{$!.class}\s#$!.message"
	end
end

command(/eval\s+(.+)/) do |obj|
	statement = obj.args[0]
	statement.gsub!(/\$|def|twitter|post/,"")
	statement.gsub!("@","@\u200b")
	obj.reply Sandbox.eval(statement)
end

command(/calc\s+(.+)/) do |obj|
	formula = obj.args[0].gsub(/[^\d+\-^*]/,"")
	formula.gsub!("^","**")
	obj.reply Sandbox.eval(formula)
end

command(/factor\s+(.+)/) do |obj|
	num = obj.args[0].to_i.abs
	res = Sandbox.eval("`factor #{num}`",0).chomp
	text = if res[-1] == ":"
		"#{num} is prime number"
	else
		"#{num} = #{res.split[1..-1].join("×")}"
	end
	obj.reply text
end
