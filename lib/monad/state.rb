require 'monad'

class State
  include Monad
  
  def initialize(&fn)
    @fn = fn
  end
  
  def call(*args)
    @fn.call(*args)
  end
  alias run call
  
  def self.return(val, &fn)
    m = new { |s| [val, s] }
    if fn then m.bind(&fn) else m end
  end
  
  def bind(&block)
    self.class.new do |s|
      v, s_ = self.call(s)
      block.call(v).call(s_)
    end
  end
  
  def self.get(&fn)
    m = new { |s| [s, s] }
    if fn then m.bind(&fn) else m end
  end
  
  def self.put(s, &fn)
    m = new { |_| [nil, s] }
    if fn then m.bind(&fn) else m end
  end
  
  def self.update(&fn)
    get { |s| put(fn.call(s)) }
  end
end
