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
end
