require "timeout"

def exec_ruby(obj)
	statement = obj.args[0]
	statement.gsub!(/\$|def|twitter|post/,"")
	statement.gsub!("@","@\u200b")
  Thread.new do
    begin
      res = Timeout::timeout 3 do
        Thread.new{$SAFE=3;instance_eval(statement)}.value
      end
    rescue Exception => e
      res = "#{e.class} #{e.message}"
    ensure
      obj.reply res
    end
  end
end

command(/eval\s+(.+)/) do |obj|
	exec_ruby(obj)
end
