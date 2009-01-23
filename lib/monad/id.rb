require 'monad'

class Id
  attr :value
  
  include Monad
  
  def initialize(val)
    @value = val
  end
  
  def self.return(val, &fn)
    m = Id.new(val)
    if fn then m.bind(&fn) else m end
  end
  
  def bind(&block)
    block.call(@value)
  end
end
