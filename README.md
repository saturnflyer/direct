# Direct

Tell your objects what to do when things work properly or when they fail.

This allows you to encapsulate behavior inside the object. Avoid using `if`
outside of your objects and just tell them what to do.

## Usage

```ruby
require 'direct'
class SomeClass
  def procedure
    Direct.defer(object: self){
      # return a truthy or falsey object
      # to execute success or failure blocks
    }
  end
end

SomeClass.new.procedure.success{ |deferred_object, result, object|
  puts "it worked!"
}.failure { |deferred_object, result, object|
  puts "it failed :-("
}.execute
```

If the example `procedure` method above raises an exception instead of just returning a falsey object, the `failure` block will be run.

But you can specify what to do when an exception is raised instead:

```ruby
SomeClass.new.procedure.success{ |deferred_object, result, object|
  puts "it worked!"
}.failure { |deferred_object, result, object|
  puts "it failed :-("
}.exception{ |deferred_object, exception, object|
  puts "Oh no! An exception was raised!"
}.execute
```

By default it will handle `StandardError` execeptions but you can be more specific if you like:

```ruby
SomeClass.new.procedure.success{ |deferred_object, result, object|
  puts "it worked!"
}.failure { |deferred_object, result, object|
  puts "it failed :-("
}.exception(SomeLibrary::SomeSpecialError){ |deferred_object, exception, object|
  puts "Oh no! An exception was raised!"
}.execute
```

The `defer` method uses built-in classes but you can build your own to manage executing named blocks

```ruby
class DeferrableClass
  include Direct

  def save
    # do stuff
    as_directed(:success, 'some', 'success', 'values')
  rescue => e
    as_directed(:failure, 'some', 'failure', e.message)
  end
end

DeferrableClass.new.direct(:success){|instance, *data|
  STDOUT.puts data
}.direct(:failure){|instance, *errors|
  STDERR.puts errors
}.save
```

Your blocks will always receive the object itself as the first argument.

## Why?

You could easily write code that says `if` this `else` that.

For example:

```ruby
if Something.new.save!
  puts "yay!"
else
  puts "boo!"
end
```

But eventually you may want more information about your successes and failures

```ruby
something = Something.new
if something.save!
  puts "yay! #{something}"
else
  puts "boo! #{something}: #{something.errors}"
end
```

That's intially not so bad that you need to initialize the object separately 
from the `if` expression. But when we discover a third or fourth scenario, then
the code can become complicated:

```ruby
something = Something.new
if something.save!
  puts "yay! #{something}"
elsif something.valid? && !something.persisted?
  puts "it sort of worked"
elsif !something.valid? || something.need_some_other_thing_set?
  puts "an alternative to it not working"
else
  puts "boo! #{something}: #{something.errors}"
end
```

It's just too easy to expand logic *and* knowledge about the internal state of
the object with `if` and `else` and `elsif`.

Instead, we can name these scenarios and allow the object to handle them; we
merely provide the block of code to execute:

```ruby
Something.new.direct(:success){ |obj|
    puts "yay! #{obj}"
  }.direct(:failure){ |obj, errors|
    puts "boo! #{obj}: #{errors}"
  }.direct(:other_scenario){ |obj|
    puts "here's what happened and what to do..."
  }
```

_Inside_ of the object is where we can handle these named scenarios. If the
meaning of `:success` or `:failure` or any other name changes, the object
itself can handle it with no changes implicitly required in the calling code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'direct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install direct

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/saturnflyer/direct. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Direct project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/saturnflyer/direct/blob/master/CODE_OF_CONDUCT.md).
