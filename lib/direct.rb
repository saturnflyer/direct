require "direct/version"
require "concurrent"

# Include this module in your classes to provide a way for
# your objects to handle named scenarios with blocks of code.
module Direct
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
  def direct(key, &block)
    __direct_store(key, block)
    self
  end

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
    __direct_store_fetch(key).each do |block|
      block.call(self, *args)
    end
  end

  private

  def __direct_store(key, block)
    @__direct_store ||= Concurrent::Map.new
    @__direct_store.put_if_absent(key, Concurrent::Array.new)
    @__direct_store.fetch(key) << block
    @__direct_store
  end

  def __direct_store_fetch(key)
    @__direct_store.fetch(key)
  end
end
