require 'monad'

module MonadReader
  def self.included(mod)
    mod.extend(ClassMethods)
  end
  
  module ClassMethods
    def self.asks(&fn)
      ask.bind { |r| fn.call(r) }
    end
  end
end

class Reader
  
  def initialize(&fn)
    @fn = fn
  end
  
  def call(*args)
    @fn.call(*args)
  end
  
  alias run call
  
  include Monad
  
  def self.return(val)
    new { |e| val }
  end
  
  def bind(&fn)
    self.class.new { |e|
      fn.call(self.call(e)).call(e) }
  end
  
  include MonadReader
  
  def self.ask
    new { |e| e }
  end
  
  def local(&fn)
    self.class.new { |e| self.call(fn.call(e)) }
  end
end

def ReaderT(inner)
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
      new { |e| @@inner.return(val) }
    end
    
    def bind(&fn)
      self.class.new { |e|
        self.call(e).bind { |val|
          fn.call(val).call(e) } }
    end
    
    def self.lift(m)
      new { |e| m }
    end
    
    include MonadReader
    
    def self.ask
      new { |e| @@inner.return(e) }
    end
    
    def local(&fn)
      self.class.new { |e| self.call(fn.call(e)) }
    end
  end
end
