module Monoid
  def self.included(mod)
    mod.extend ClassMethods
  end

  module ClassMethods
    def mconcat(ms)
      ms.inject(mempty) { |a,b| a.mappend(b) }
    end
  end
end

class Array
  include Monoid
  
  def self.mempty; [] end
  
  def mappend(lst) self + lst end
end

class String
  include Monoid
  
  def self.mempty; "" end
  
  def mappend(str) self + str end
end

class Hash
  include Monoid
  
  def self.mempty; {} end
  
  def mappend(hsh) merge(hsh) end
end

class Proc
  include Monoid
  
  def self.mempty
    fn = new { |x| fn }
  end

  def mappend(fn)
    self.class.new { |x| self.call(x).mappend(fn.call(x)) }
  end
end
