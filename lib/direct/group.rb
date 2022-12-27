require "concurrent"
module Direct
  class Group
    def initialize
      @map = Concurrent::Map.new { |collection, key|
        collection.put(key, Concurrent::Array.new)
      }
    end

    attr_reader :map
    private :map

    def store(key, callable = nil, &block)
      map[key] << (callable || block)
      self
    end

    def fetch(key)
      map.fetch(key)
    end

    def key?(key)
      map.key?(key)
    end

    def empty?
      map.empty?
    end

    def inspect
      map.keys.inspect
    end
  end

  private_constant :Group
end
