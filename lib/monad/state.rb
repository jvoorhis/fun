require 'monad'

module MonadState

  def self.included(mod)
    mod.extend(ClassMethods)
  end
  
  module ClassMethods
    def update(&fn)
      get.bind { |s| put(fn.call(s)) }
    end
  end
end

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
    new { |s| [val, s] }
  end
  
  def bind(&block)
    self.class.new do |s|
      v, s1 = self.call(s)
      block.call(v).call(s1)
    end
  end
  
  include MonadState
  
  def self.get(&fn)
    new { |s| [s, s] }
  end
  
  def self.put(s, &fn)
    new { |_| [nil, s] }
  end
end

def StateT(inner)
  Class.new do
    @@inner = inner
    
    def initialize(&fn)
      @fn = fn
    end
    
    def call(*args)
      @fn.call(*args)
    end
    
    alias run call
    
    include Monad
    
    def self.return(val)
      new { |s| @@inner.return([val, s]) }
    end
    
    def bind(&fn)
      self.class.new do |s|
        self.call(s).bind do |(v,s1)|
          fn.call(v).call(s1)
        end
      end
    end
    
    include MonadState
    
    def self.get(&fn)
      new { |s| @@inner.return([s, s]) }
    end
    
    def self.put(s, &fn)
      new { |_| @@inner.return([nil, s]) }
    end    
  end
end
