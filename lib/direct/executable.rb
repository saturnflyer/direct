module Direct
  class Executable
    include Direct.allow_missing_directions

    # It is intended that you initialize objects via Direct.defer
    # and not directly initializing this class.
    #
    # You may initialize this class and provide an object which
    # responds to "call" or a block to execute.
    #
    # Example:
    #
    #   Direct.defer do
    #     puts "see ya later!"
    #   end
    #
    #   Direct.defer(->{ "call me, maybe" })
    #
    def initialize(callable=nil, object: nil, &block)
      @object = object
      @execution = callable || block
      @exception_classes = [StandardError]
    end
    attr_reader :execution, :exception_classes, :object

    # Tell the object what to do for a success path
    #
    # Returns itself
    #
    def success(callable=nil, &block)
      direct(:success, (callable || block))
      self
    end

    # Tell the object what to do for a failure path
    #
    # Returns itself
    #
    def failure(callable=nil, &block)
      direct(:failure, (callable || block))
      self
    end

    # Tell the object what to do for an exception path.
    #
    # You may optionally provide a list of modules rescued by
    # the value method in the case of an exception.
    #
    # Returns itself
    #
    # Example:
    #
    #   Direct.defer {
    #      # something...
    #   }.exception(NoMethodError) { |deferred, exception|
    #      ExceptionNotifier.notify(exception)
    #   }
    #
    def exception(*classes, &block)
      unless classes.empty?
        @exception_classes = classes
      end
      direct(:exception, block)
      self
    end

    def run_exception_block(exception)
      if __directions.key?(:exception)
        as_directed(:exception, object, exception)
      else
        as_directed(:failure, object, exception)
      end
    end
    private :run_exception_block

    # Return the value of the success or failure path
    # and rescue from StandardError or from the modules
    # provided to the exception path.
    #
    def value
      result = execution.()
      if result
        as_directed(:success, object, result)
      else
        as_directed(:failure, object, result)
      end
    rescue *exception_classes => exception
      run_exception_block(exception)
    end
    alias execute value
  end
end
