module Direct
  # This class monitors exception types with related blocks.
  class ExceptionHandler
    def initialize
      @handlers = {}
      @classes_cache = nil
    end

    # All classes, including StandardError, for which this object
    # maintains a block to execute.
    def classes
      @classes_cache ||= begin
        return [StandardError] if @handlers.empty?
        [StandardError, *@handlers.keys.flatten].uniq
      end
    end

    # Pass a single or multiple exception classes and the block
    # to be used to handle them.
    def monitor(*classes, &block)
      @handlers[classes.flatten] = block
      @classes_cache = nil
    end

    # This will find the first handler given to `monitor` which matches
    # the provided exception's class and will execute it with the
    # deferred object, the exception object, and any given object to the
    # deferred object.
    def call(deferred, exception, object)
      exception_class = exception.class

      # Fast path: exact class match
      result = @handlers.find { |keys, _| keys.include?(exception_class) }
      return result.last.call(deferred, exception, object) if result

      # Slow path: inheritance check
      result = @handlers.find do |keys, _|
        keys.any? { |klass| exception_class < klass }
      end

      if result
        result.last.call(deferred, exception, object)
      else
        raise "No handler for this exception: #{exception_class}!"
      end
    end
  end
end
