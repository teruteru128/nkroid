class Accounts
  attr_reader :list
  def initialize
    @list = []
    @keys = []
    @cursor = 0
  end

  def add(key)
    @keys << key
    @list << Twitter::REST::Client.new(key)
  end

  def load_yaml(path)
    keys = YAML.load_file(path)
    keys.each{|key|add(key)}
  end

  def main
    @list[0] end
  def stream
    Twitter::Streaming::Client.new(@keys[0]) end

  def next
    @cursor == @list.length-1 ? @cursor = 0 : @cursor+=1 end
  def now
    @list[@cursor] end
end

$accounts = Accounts.new
$accounts.load_yaml("./config/keys.yml")

def accounts
  $accounts end
def twitter
  accounts.now end
