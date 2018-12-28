require "test_helper"

class Later
  include Direct

  def perform(callable)
    Direct.defer {
      if callable.()
        true # run the success block
      else
        false # run the failure block
      end
    }
  end
end


class ExecutableTest < Minitest::Test
  def perform(&block)
    Later.new.
      perform(block).
      success{|result| "succeeded!" }.
      failure{|result| "failed!" }.
      exception(NoMethodError){|result| "oops! no method!" }.
      value
  end

  def test_that_it_runs_success_path
    assert_match(/succeeded!/, perform { true })
  end

  def test_that_it_runs_failure_path
    assert_match(/failed!/, perform { false })
  end

  def test_that_it_runs_exception_path
    assert_match(/oops! no method!/, perform { Object.no_method })
  end
end
