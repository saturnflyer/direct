module Direct
  class Executable
    def initialize(&block)
      @execution = block
      @success = @failure = proc{}
      @exception_classes = [StandardError]
    end
    attr_reader :execution, :exception_classes

    def success(&block)
      @success = block
      self
    end

    def failure(&block)
      @failure = block
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
      @exception_block || @failure
    end

    def value
      result = execution.()
      if result
        @success.(result)
      else
        @failure.(result)
      end
    rescue *exception_classes => e
      exception_block.(e)
    end
    alias execute value
  end
end
