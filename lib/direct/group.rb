require 'concurrent'
module Direct
  class Group
    def initialize
      @map = Concurrent::Map.new{|collection, key|
        collection.put(key, Concurrent::Array.new)
      }
    end

    attr_reader :map
    private :map

    def store(key, &block)
      map[key] << block
      self
    end

    def fetch(key)
      map.fetch(key)
    end
  end
end
