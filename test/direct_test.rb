require "test_helper"

class Something
  include Direct

  def initialize(save:true)
    @save = save
  end
  attr_reader :save

  def save!
    if save
      as_directed(:success)
    else
      as_directed(:failure, "oops!")
    end
  end

  def unknown
    as_directed(:missing_procedure)
  end
end


class DirectTest < Minitest::Test
  def do_it(save: true)
    Something.new(save: save).direct(:success){ |something|
      @result = "it worked! #{something}"
    }.direct(:failure){ |something, errors|
      @result = "it failed! #{errors}"
    }.save!
    @result
  end

  def test_that_it_runs_success_path
    assert_match(/it worked\!.*Something/, do_it(save: true))
  end

  def test_that_it_runs_failure_path
    assert_equal("it failed! oops!", do_it(save: false))
  end

  def test_that_it_runs_multiple_blocks
    @results = []
    Something.new.
      direct(:failure){|_| @results << "nope" }.
      direct(:success){|_| @results << "first" }.
      direct(:success){|_| @results << "second" }.
      save!

    assert_equal ["first", "second"], @results
  end

  def test_that_it_runs_multiple_alternate_blocks
    @results = []
    Something.new(save: false).
      direct(:success){|_| @results << "nope" }.
      direct(:failure){|_| @results << "first" }.
      direct(:failure){|_| @results << "second" }.
      save!

    assert_equal ["first", "second"], @results
  end

  def  test_that_it_raises_error_for_unknown_direction
    err = assert_raises(Direct::MissingProcedure) do
      Something.new.unknown
    end
    assert_match(/Procedure for :missing_procedure was reached but not specified./, err.message)
  end
end
