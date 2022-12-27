require "test_helper"

class Exceptional
  def perform(callable)
    Direct.strict_defer {
      callable.call
    }
  end
end

class Raiser
  def fail
    raise StandardError, "oops!"
  end

  def needs_args(one, two)
    puts [one, two]
  end
end

class MultipleExceptionsTest < Minitest::Test
  def perform(&block)
    Exceptional.new
      .perform(block)
      .success { "succeeded!" }
      .failure { "failed!" }
      .exception(NoMethodError) { "oops! no method!" }
      .exception(StandardError) { "oops! standard error" }
      .exception(ArgumentError) { "oops! arg error" }
      .value
  end

  def test_it_handles_multiple_exceptions
    assert_equal(["oops! standard error"], perform { Raiser.new.fail })
  end

  def test_it_handles_argument_exceptions
    assert_equal(["oops! arg error"], perform { Raiser.new.needs_args })
  end
end
