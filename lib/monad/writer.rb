require 'monad'
require 'monoid'

module MonadWriter
  def listens(&fn)
    bind do |(val, log)|
      self.class.return([val, fn.call(log)])
    end
  end
  
  def censor(&fn)
    bind { |val| self.class.return([val, fn]) }.pass
  end
end

def Writer(log_type)
  Class.new do
    @@log_type = log_type
    
    attr_reader :value, :log
    
    def initialize(val, log)
      @value, @log = val, log
    end
    
    include Monad
    
    def self.return(val)
      new(val, @@log_type.mempty)
    end
    
    def bind(&fn)
      w1 = fn.call(value)
      self.class.new(w1.value, log.mappend(w1.log))
    end
    
    include MonadWriter
    
    def self.tell(log)
      new(nil, log)
    end
    
    def pass
      (v, fn) = value
      self.class.new(v, fn.call(log))
    end
    
    def listen
      self.class.new([value, log], log)
    end
  end
end

def WriterT(log_type, inner)
  Class.new do
    @@log_type = log_type
    @@inner    = inner

    attr_reader :value
    
    def initialize(val)
      @value = val
    end
    
    include Monad
    
    def self.return(val)
      new(@@inner.return([val, @@log_type.mempty]))
    end
    
    def bind(&fn)
      self.class.new value.bind { |(a,log)|
        fn.call(a).value.bind { |(b,log_)|
          @@inner.return([b, log.mappend(log_)]) } }
    end
    
    def self.lift(m)
      new m.bind { |val| @@inner.return([val, @@log_type.mempty]) }
    end
    
    include MonadWriter
    
    def self.tell(log)
      new(@@inner.return([nil, log]))
    end
    
    def pass
      value.bind do |((val,fn), log)|
        self.class.new(@@inner.return([val, fn.call(log)]))
      end
    end
    
    def listen
      self.class.new value.bind { |(val,log)|
        @@inner.return([[val,log], log]) }
    end
  end
end
