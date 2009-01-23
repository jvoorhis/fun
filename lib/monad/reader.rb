require 'monad'

class Reader
  include Monad
  
  def initialize(&fn)
    @fn = fn
  end

  def call(*args)
    @fn.call(*args)
  end
  
  alias run call
  
  def self.return(val, &fn)
    m = Reader.new { |e| val }
    if fn then m.bind(&fn) else m end
  end

  def bind(&fn)
    Reader.new do |e|
      fn.call(self.call(e)).call(e)
    end
  end

  def self.ask(&fn)
    m = Reader.new { |e| e }
    if fn then m.bind(&fn) else m end
  end

  def self.asks(&fn)
    Reader.ask.bind { |r| fn.call(r) }
  end
end
