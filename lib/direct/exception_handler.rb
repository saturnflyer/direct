module Direct
  # This class monitors exception types with related blocks.
  class ExceptionHandler
    def initialize
      @handlers = {}
    end

    # All classes, including StandardError, for which this object
    # maintains a block to execute.
    def classes
      [StandardError, @handlers.keys.flatten].flatten
    end

    # Pass a single or multiple exception classes and the block
    # to be used to handle them.
    def monitor(*classes, &block)
      @handlers[classes.flatten] = block
    end

    # This will find the first handler given to `monitor` which matches
    # the provided exception's class and will execute it with the
    # deferred object, the exception object, and any given object to the
    # deferred object.
    def call(deferred, exception, object)
      if_none = proc { raise "No handler for this exception: #{exception.class}!" }
      result = @handlers.find { |key, val| key.include?(exception.class) }
      if result.nil?
        result = @handlers.find(if_none) do |key, val|
          key.find { |klass| exception.class < klass }
        end
      end

      result.last.call(deferred, exception, object)
    end
  end
end
