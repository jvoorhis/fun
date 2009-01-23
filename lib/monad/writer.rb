require 'monad'

module MonadWriter
  def listens(&fn)
    bind do |(v, l)|
      self.class.return(v, fn.call(l))
    end
  end
  
  def censor(&fn)
    bind { |v| self.class.return([v, fn]) }.pass
  end
end

def Writer(log_type)
  Class.new do
    @@log_type = log_type
    
    include Monad
    include MonadWriter
    
    attr_reader :value, :log
    
    def initialize(val, log)
      @value, @log = val, log
    end
    
    def self.return(val)
      new(val, @@log_type.mempty)
    end
    
    def bind(&fn)
      w1 = fn.call(@value)
      self.class.new(w1.value, @log.mappend(w1.log))
    end
    
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
