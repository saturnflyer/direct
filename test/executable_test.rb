require "test_helper"

class NotNow
  def perform(callable)
    Direct.defer {
      callable.call
    }
  end

  def do_more(callable)
    Direct.defer(callable, "some", "args", and: "more")
  end
end

class ExecutableTest < Minitest::Test
  def perform(&block)
    NotNow.new
      .perform(block)
      .exception(NoMethodError) { "oops! no method!" }
      .value
  end

  def test_that_it_runs_success_path
    assert perform { true }
  end

  def test_that_it_runs_failure_path
    refute perform { false }
  end

  def test_that_it_runs_exception_path
    assert_equal(["oops! no method!"], perform { Object.no_method })
  end

  def test_that_it_runs_failure_with_no_exception_block
    deferred = NotNow.new
      .perform(-> { raise StandardError })
      .success { "this should not happen" }
      .failure { "failure block as expected!" }

    assert_equal(["failure block as expected!"], deferred.value)
  end

  def test_that_it_allows_additional_keys
    deferred = NotNow.new.perform(-> { "it works!" })
    deferred.direct(:alternate) { "the alternate works!" }
    assert_equal(["the alternate works!"], deferred.as_directed(:alternate))
  end

  def test_that_it_passes_exception_object_to_exception_block
    deferred = NotNow.new
      .perform(-> { raise StandardError, "oopsie!" })
      .exception { |obj, exception| exception.message }

    assert_equal(["oopsie!"], deferred.value)
  end

  def test_that_it_checks_for_exception_inheritance
    deferred = NotNow.new
      .perform(-> { raise NoMethodError, "That method doesn't exist" })
      .exception(StandardError) { |obj, exception| exception.message }

    assert_equal(["That method doesn't exist"], deferred.value)
  end

  def test_that_it_passes_additional_args
    deferred = NotNow.new
      .do_more(-> { true })
      .success { |deferred, result, object, *args, **kwargs| {args: args, kwargs: kwargs} }

    assert_equal([{args: ["some", "args"], kwargs: {and: "more"}}], deferred.value)
  end
end

class ExecutableTestWithBlocks < Minitest::Test
  def perform(&block)
    NotNow.new
      .perform(block)
      .success { "succeeded!" }
      .failure { "failed!" }
      .exception(NoMethodError) { "oops! no method!" }
      .value
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
    deferred = NotNow.new
      .perform(-> { raise StandardError })
      .success { "this should not happen" }
      .failure { "failure block as expected!" }

    assert_equal(["failure block as expected!"], deferred.value)
  end

  def test_that_it_allows_additional_keys
    deferred = NotNow.new.perform(-> { "it works!" })
    deferred.direct(:alternate) { "the alternate works!" }
    assert_equal(["the alternate works!"], deferred.as_directed(:alternate))
  end

  def test_that_it_passes_exception_object_to_exception_block
    deferred = NotNow.new
      .perform(-> { raise StandardError, "oopsie!" })
      .exception { |deferred, exception, object| exception.message }

    assert_equal(["oopsie!"], deferred.value)
  end
end
