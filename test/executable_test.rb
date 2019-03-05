require "test_helper"

class NotNow
  def perform(callable)
    Direct.defer {
      callable.()
    }
  end
end


class ExecutableTest < Minitest::Test
  def perform(&block)
    NotNow.new.
      perform(block).
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
    deferred = NotNow.new.
      perform(->{ raise StandardError }).
      success{ "this should not happen" }.
      failure{ "failure block as expected!" }

      assert_equal(["failure block as expected!"], deferred.value)
  end

  def test_that_it_allows_additional_keys
    deferred = NotNow.new.perform(->{ "it works!" })
    deferred.direct(:alternate){ "the alternate works!" }
    assert_equal(["the alternate works!"], deferred.as_directed(:alternate))
  end

  def test_that_it_passes_exception_object_to_exception_block
    deferred = NotNow.new.
      perform(->{ raise StandardError, "oopsie!" }).
      exception{|obj, exception| exception.message }

    assert_equal(["oopsie!"], deferred.value)
  end
end


class ExecutableTestWithBlocks < Minitest::Test
  def perform(&block)
    NotNow.new.
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
    deferred = NotNow.new.
      perform(->{ raise StandardError }).
      success{ "this should not happen" }.
      failure{ "failure block as expected!" }

      assert_equal(["failure block as expected!"], deferred.value)
  end

  def test_that_it_allows_additional_keys
    deferred = NotNow.new.perform(->{ "it works!" })
    deferred.direct(:alternate){ "the alternate works!" }
    assert_equal(["the alternate works!"], deferred.as_directed(:alternate))
  end

  def test_that_it_passes_exception_object_to_exception_block
    deferred = NotNow.new.
      perform(->{ raise StandardError, "oopsie!" }).
      exception{|obj, exception| exception.message }

    assert_equal(["oopsie!"], deferred.value)
  end
end
