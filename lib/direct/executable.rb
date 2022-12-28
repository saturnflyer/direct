require "direct/exception_handler"

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
    # You may also provide an 'object:' parameter which will be
    # passed to the provided blocks when they are ultimately executed
    #
    # Example:
    #
    #   Direct.defer(object: self) do
    #     # do work here
    #   end.success {|deferred, deferred_block_result, object|
    #     # you have access to the provided object here
    #   }
    #
    # The object is a useful reference because the Executable instance
    # is the deferred object, instead of the object using Direct.defer
    #
    #   class Thing
    #     def do_something
    #       Direct.defer(object: self){ do_the_work }
    #     end
    #   end
    #
    #   Thing.new.do_something.success {|deferred, result, thing|
    #      puts "The #{thing} did something!"
    #   }.execute
    #
    def initialize(callable = nil, *args, **kwargs, &block)
      @object = kwargs.delete(:object)
      @args = args
      @kwargs = kwargs
      @exception_handler = kwargs.delete(:exception_handler) || ExceptionHandler.new
      @execution = callable || block
    end
    attr_reader :execution, :exception_handler, :object, :args, :kwargs

    # Tell the object what to do for a success path
    #
    # Returns itself
    #
    def success(callable = nil, &block)
      direct(:success, (callable || block))
      self
    end

    # Tell the object what to do for a failure path
    #
    # Returns itself
    #
    def failure(callable = nil, &block)
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
    #   }.exception(NoMethodError) { |deferred, exception, object|
    #      ExceptionNotifier.notify(exception)
    #   }
    #
    def exception(*classes, &block)
      classes = [StandardError] if classes.empty?
      exception_handler.monitor(classes, &block)

      direct(:exception, exception_handler)
      self
    end

    def exception_classes
      exception_handler.classes
    end

    def run_exception_block(exception)
      if __directions.key?(:exception)
        as_directed(:exception, exception, object, *args, *kwargs)
      else
        as_directed(:failure, exception, object, *args, *kwargs)
      end
    end
    private :run_exception_block

    # Return the value of the success or failure path
    # and rescue from StandardError or from the modules
    # provided to the exception path.
    #
    def value
      result = execution.call
      if result
        as_directed(:success, result, object, *args, *kwargs)
      else
        as_directed(:failure, result, object, *args, *kwargs)
      end || result
    rescue *exception_classes => exception
      run_exception_block(exception)
    end
    alias_method :execute, :value
  end

  private_constant :Executable
end
