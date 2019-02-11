module Direct
  class Executable
    include Direct

    def initialize(callable=nil, &block)
      @execution = callable || block
      @exception_classes = [StandardError]
    end
    attr_reader :execution, :exception_classes

    def success(callable=nil, &block)
      direct(:success, (callable || block))
      self
    end

    def failure(callable=nil, &block)
      direct(:failure, (callable || block))
      self
    end

    def exception(*classes, &block)
      unless classes.empty?
        @exception_classes = classes
      end
      direct(:exception, block)
      self
    end

    def run_exception_block
      if __directions.key?(:exception)
        as_directed(:exception)
      else
        as_directed(:failure)
      end
    end
    private :run_exception_block

    def value
      result = execution.()
      if result
        as_directed(:success, result)
      else
        as_directed(:failure, result)
      end
    rescue *exception_classes
      run_exception_block
    end
    alias execute value
  end
  private_constant :Executable
end
