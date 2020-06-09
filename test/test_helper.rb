require "simplecov"
require "pry-byebug"
SimpleCov.start do
  add_filter "test"
end
require "minitest/autorun"
require "direct"
