module Monad
  def self.included(mod)
    mod.send(:include, InstanceMethods)
    mod.extend(ClassMethods)
  end
  
  module InstanceMethods
    def fmap(&fn)
      self.bind { |v| self.class.return(fn.call(v)) }
    end
    
    def seq(m = nil, &fn)
      self.bind { |_| m.nil? ? fn.call() : m }
    end
  end
  
  module ClassMethods
    def sequence(ms)
      ms.inject( self.return([]) ) do |m_, m|
        m.bind do |x|
          m_.bind do |xs|
            self.return( [x] + xs )
          end
        end
      end
    end
    
    def mapM(as, &fn)
      sequence( as.map(&fn) )
    end
    
    def liftM(*ms, &block)
      if ms.size != block.arity && block.arity != -1
        raise ArgumentError, "Given #{ms.size} args, and block of #{block.arity} args."
      end
      
      case ms.size
        when 1: liftM1(*ms, &block)
        when 2: liftM2(*ms, &block)
        when 3: liftM3(*ms, &block)
        else raise NotImplementedError, "liftM#{ms.size} is undefined."
      end
    end
    
    def liftM1(m1, &fn)
      m1.bind { |v1| m1.class.return(fn.call(v1)) }
    end
    
    def liftM2(m1, m2, &fn)
      m1.bind do |v1|
        m2.bind do |v2|
          m1.class.return(fn.call(v1, v2))
        end
      end
    end
    
    def liftM3(m1, m2, m3, &fn)
      m1.bind do |v1|
        m2.bind do |v2|
          m3.bind do |v3|
            m1.class.return(fn.call(v1, v2, v3))
          end
        end
      end
    end
  end
end
