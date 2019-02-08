require "direct/version"
require "direct/executable"
require "direct/group"

# Include this module in your classes to provide a way for
# your objects to handle named scenarios with blocks of code.
module Direct
  class MissingProcedure < StandardError; end

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
  #   do_it.
  #     success{|result| puts "it worked!" }.
  #     failure{|result| puts "it failed!" }
  #
  def self.defer(&block)
    Executable.new(&block)
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
  # Your blocks will always receive the object itself as the first argument.
  #
  def direct(key, callable=nil, &block)
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
  def as_directed(key, *args)
    __directions.fetch(key).map do |block|
      block.call(self, *args)
    end
  rescue KeyError
    raise MissingProcedure, "Procedure for :#{key} was reached but not specified."
  end

  private

  def __directions
    @__directions ||= Direct::Group.new
  end
end
