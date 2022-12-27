module Direct
  class ExceptionHandler
    def initialize
      @handlers = {}
    end

    def classes
      [StandardError, @handlers.keys.flatten].flatten
    end

    def monitor(*classes, &block)
      @handlers[classes.flatten] = block
    end

    def call(deferred, exception, object)
      if_none = proc() { raise "No handler for this exception: #{exception.class}!" }
      result = @handlers.find(if_none) { |key, val| key.include?(exception.class) }

      result.last.call(deferred, exception, object)
    end
  end
end
