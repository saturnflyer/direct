require "test_helper"

class Later
  include Direct

  def perform(callable)
    Direct.defer {
      callable.()
    }
  end
end


class ExecutableTest < Minitest::Test
  def perform(&block)
    Later.new.
      perform(block).
      success{ "succeeded!" }.
      failure{ "failed!" }.
      exception(NoMethodError){ "oops! no method!" }.
      value
  end

  def test_that_it_runs_success_path
    assert_equal(["succeeded!"], perform { true })
  end

  def test_that_it_runs_failure_path
    assert_equal(["failed!"], perform { false })
  end

  def test_that_it_runs_exception_path
    assert_equal(["oops! no method!"], perform { Object.no_method })
  end

  def test_that_it_runs_failure_with_no_exception_block
    deferred = Later.new.
      perform(->{ raise StandardError }).
      success{ "this should not happen" }.
      failure{ "failure block as expected!" }

      assert_equal(["failure block as expected!"], deferred.value)
  end
end
