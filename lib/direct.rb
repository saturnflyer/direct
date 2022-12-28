require "direct/version"
# Include this module in your classes to provide a way for
# your objects to handle named scenarios with blocks of code.
module Direct
  class MissingProcedure < StandardError; end

  module AllowMissing
    include Direct
    def allow_missing_directions?
      true
    end
  end

  # Use this module to allow your procedures to go ignored.
  #
  # Example:
  #
  #   class Thing < ActiveRecord::Base
  #     include Direct.allow_missing_directions
  #
  #     def save(*)
  #       super
  #       as_directed(:success)
  #     end
  #   end
  #
  #   Thing.new.save # => no MissingProcedure error raised.
  #
  def self.allow_missing_directions
    AllowMissing
  end
end

require "direct/executable"
require "direct/strict_executable"
require "direct/group"

module Direct
  # Wrap a block of code to return an object for handling
  # success or failure. Raises exceptions when directions
  # are not provided
  #
  # Example:
  #
  #   def do_it
  #     Direct.strict_defer{
  #       [true, false].sample
  #     }
  #   end
  #   do_it.
  #     success{|result| puts "it worked!" }.
  #     failure{|result| puts "it failed!" }.
  #     value
  #
  def self.strict_defer(callable = nil, *args, object: nil, **kwargs, &block)
    StrictExecutable.new(callable, *args, object: object, **kwargs, &block)
  end

  # Wrap a block of code to return an object for handling
  # success or failure.
  #
  # Example:
  #
  #   def do_it
  #     Direct.defer{
  #       [true, false].sample
  #     }
  #   end
  #   do_it.value
  #
  def self.defer(callable = nil, *args, object: nil, **kwargs, &block)
    Executable.new(callable, *args, object: object, **kwargs, &block)
  end

  # Tell the object what to do in a given scenario.
  #
  # object.direct(:success){|obj| puts "it worked!" }
  # object.direct(:failure){|obj| puts "it failed!" }
  #
  # You may also chain calls to this method
  #
  # object.direct(:success){ |obj|
  #   puts "it worked!"
  # }.direct(:failure){ |obj|
  #   puts "it failed!"
  # }.do_it
  #
  # Your blocks will *always* receive the object itself as the first argument.
  #
  def direct(key, callable = nil, &block)
    __directions.store(key, callable || block)
    self
  end
  alias_method :when, :direct

  # Perform the named block of code
  #
  # def do_it
  #   # do things here
  #   as_directed(:success, "success", "messages")
  # rescue => e
  #   as_directed(:failure, errors)
  # end
  #
  # This will raise an error if the provided key is not found
  #
  # The current value for self will be sent as the first argument to the block
  def as_directed(key, ...)
    return if allow_missing_directions? && __directions.empty?
    __directions.fetch(key).map do |block|
      block.call(self, ...)
    end
  rescue KeyError
    return if allow_missing_directions?
    raise MissingProcedure, "Procedure for :#{key} was reached but not specified."
  end

  private

  def allow_missing_directions?
    false
  end

  def __directions
    @__directions ||= Group.new
  end
end
