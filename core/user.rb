$user_status = Hash.new(Array.new)
$user_data = {}

class Twitter::User
  def use(name)
    $user_status[self.id] << name end
  def using?
    !!$user_status[self.id] end
  def using_by?(name)
    $user_status[self.id].include? name end
  def unuse(name)
    $user_status[self.id].delete name end
  def clear
    $user_status.delete self.id end
  def data(type)
    $user_data[type] end
end
