require 'monad'
require 'monad_plus'

class Array
  include Monad
  include MonadPlus
  
  def self.return(val, &fn)
    m = [val]
    if fn then m.bind(&fn) else m end
  end
  
  def bind(&block)
    map { |e| block.call(e) }.mjoin
  end
  
  def mjoin
    inject([]) { |out, arr| out + arr }
  end
  
  def self.mzero
    []
  end
  
  def mplus(m)
    self + m
  end
end
