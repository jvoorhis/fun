require 'monad'
require 'monad_plus'

class Array
  include Monad
  include MonadPlus
  
  def self.return(val, &fn)
    m = [val]
    if fn then m.bind(&fn) else m end
  end
  
  def bind(&fn)
    map { |e| fn.call(e) }.mjoin
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

def ArrayT(inner)
  Class.new do
    @@inner = inner
    
    attr_reader :arr
    
    def initialize(arr)
      @arr = arr
    end
    
    include Monad
    
    def self.return(val)
      new(@@inner.return([val]))
    end
    
    def bind(&fn)
      self.class.new arr.bind { |a|
        @@inner.mapM(a) { |e| fn.call(e).arr }.bind { |b|
          @@inner.return(b.inject([]) { |out, arr| arr + out }) } }
    end
    
    include MonadPlus
    
    def self.mzero
      new(@@inner.return([]))
    end

    def mplus(m)
      self.class.new arr.bind { |a|
        m.arr.bind { |b|
          @@inner.return(a + b) } }
    end
  end
end
