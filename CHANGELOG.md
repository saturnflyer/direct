## Version 2.1.0

Check for inheritance on exception handler exceptions.
## Version 2.0.1

Introduce an ExceptionHandler to allow for multiple exception blocks
Drop Ruby 2.6 support
Fix bug where strict_defer was not accepting callable and object arguments.
Drop Ruby 2.5 and below

## Version 2.0.0

A bug in deferred execution did not return the success/failure results. Fixes test names that cause a collision and incorrect test scenarios.

## Version 1.2.1

Provide an 'object:' to a Direct.defer or Direct.strict_defer to be sent as the third parameter in the executed blocks.

## Version 1.2.0

Provide a Direct.defer and Direct.strict_defer to allow deferring blocks without success and failure procedures.

## Version 1.1.1

Include Direct.allow_missing_directions to allow as_directed to be ignored when missing.

## Version 1.1.0

Use Direct module to build deferred object internals.

## Version 1.0.0

Initial release
