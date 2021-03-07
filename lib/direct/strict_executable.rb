module Direct
  class StrictExecutable < Executable
    include Direct

    # It is intended that you initialize objects via Direct.strict_defer
    # and not directly initializing this class.
    #
    # You may initialize this class and provide an object which
    # responds to "call" or a block to execute.
    #
    # Example:
    #
    #   Direct.strict_defer do
    #     puts "see ya later!"
    #   end
    #
    #   Direct.strict_defer(->{ "call me, maybe" })
    #
    # You may also provide an 'object:' parameter which will be
    # passed to the provided blocks when they are ultimately executed
    #
    # Example:
    #
    #   Direct.strict_defer(object: self) do
    #     # do work here
    #   end.success {|deferred, deferred_block_result, object|
    #     # you have access to the provided object here
    #   }
    #
    # The object is a useful reference because the Executable instance
    # is the deferred object, instead of the object using Direct.strict_defer
    #
    #   class Thing
    #     def do_something
    #       Direct.strict_defer(object: self){ do_the_work }
    #     end
    #   end
    #
    #   Thing.new.do_something.success {|deferred, result, thing|
    #      puts "The #{thing} did something!"
    #   }.failure{|_,_,thing|
    #      puts "#{thing} failed!"
    #   }.execute
    #

    # Return the value of the success or failure path
    # and rescue from StandardError or from the modules
    # provided to the exception path.
    #
    def value
      result = execution.()
      if result
        as_directed(:success, result)
      else
        as_directed(:failure, result)
      end
    rescue *exception_classes => exception
      run_exception_block(exception)
    end
    alias execute value
  end
end
