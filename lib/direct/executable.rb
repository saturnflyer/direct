module Direct
  class Executable
    def initialize(&block)
      @execution = block
      @success_block = @failure_block = proc{}
      @exception_modules = [StandardError]
    end
    attr_reader :execution

    def success(&block)
      @success_block = block
      self
    end

    def failure(&block)
      @failure_block = block
      self
    end

    def exception(*classes, &block)
      unless classes.empty?
        @exception_classes = classes
      end
      @exception_block = block
      self
    end

    def exception_block
      @exception_block || @failure_block
    end

    def value
      result = execution.call
      if result
        @success_block.(result)
      else
        @failure_block.(result)
      end
    rescue *@exception_classes => e
      exception_block.(e)
    end
    alias execute value
  end
end
