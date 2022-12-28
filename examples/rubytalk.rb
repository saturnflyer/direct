require "direct"

class Operation
  include Direct

  def initialize(&block)
    @block = block
    @exception_handler = Direct::ExceptionHandler.new
  end

  def if_true(&)
    direct(:if_true, &)
  end

  def if_false(&)
    direct(:if_false, &)
  end

  def if_exception(type = RuntimeError, &)
    @exception_handler.monitor(type, &)
    direct(:if_exception, @exception_handler)
  end

  def call
    if @block.call
      as_directed(:if_true)
    else
      as_directed(:if_false)
    end
  rescue *@exception_handler.classes => e
    as_directed(:if_exception, e, self)
  end
end

def Operation(&block)
  Operation.new(&block)
end

Operation { [true, false].sample }
  .if_true { puts "yay!" }
  .if_false { puts "boo!" }
  .if_exception { puts "oops!" }
  .call
