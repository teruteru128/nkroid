require "timeout"

class SandBox
  def self.eval(code)
    throw ArgumentError, "callback not given" unless block_given?
    result_or_error = nil
    begin
      Timeout::timeout 3 do
        result_or_error = Thread.new do
          $SAFE = 3
          instance_eval code
        end.value
      end
    rescue StandardError, SecurityError, Timeout::Error => e
      result_or_error = e
    end
    yield result_or_error
  end
end

def exec_ruby(obj)
	statement = obj.args[0]
	statement.gsub!(/\$|def|twitter|post/,"")
	statement.gsub!("@","@\u200b")
	SandBox.eval(statement) do |res|
		obj.reply res,false
	end
rescue Exception => e
	obj.reply "#{e.class} #{e.message}"
	return
end

command(/eval\s+(.+)/) do |obj|
	exec_ruby(obj)
end