require "direct"

class Operation
  include Direct

  def initialize(&block)
    @block = block
  end

  def if_true(&)
    direct(:if_true, &)
  end

  def if_false(&)
    direct(:if_false, &)
  end

  def call
    if @block.call
      as_directed(:if_true)
    else
      as_directed(:if_false)
    end
  end
end

def Operation(&block)
  Operation.new(&block)
end

Operation { [true, false].sample }
  .if_true { puts "yay!" }
  .if_false { puts "boo!" }
  .call
