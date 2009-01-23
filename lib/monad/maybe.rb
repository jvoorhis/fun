require 'monad'
require 'monad_plus'

class Maybe
  def self.return(val, &fn)
    m = Just.new(val)
    if fn then m.bind(&fn) else m end
  end

  def self.mzero
    Nothing
  end
end

class Just < Maybe
  attr :value
  
  def initialize(val)
    @value = val
  end

  def bind(&block)
    block.call(value)
  end

  def mplus(m)
    self
  end
end

class NothingClass < Maybe
  def bind(&block)
    self
  end

  def mplus(m)
    m
  end
end
Nothing = NothingClass.new unless defined?(Nothing)
