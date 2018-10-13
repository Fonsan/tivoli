# Tivoli

http://en.wikipedia.org/wiki/Aspect-oriented_programming

## Usage
```ruby
  t = Tivoli.new(String.instance_method(:+))
  t.aspect :before do |time, args, &block|
    # log stuff here or
    puts "LOG #doargsend"
  end
  "hello" + "other" # => 'helloother'
  LOG ['other']

  t.aspect :before do |time, args, &block|
    # change arguments
    args[0].reverse!
  end
  'hello' + 'other' # => 'helloretho'

  # prev is used for chaining multiple filters, first time prev is nil
  t.filter :before do |prev, time, args, &block|
    # change result
    'nope'
  end
  'hello' + 'other' # => 'nope'

  t.aspect :before do
    sleep 1
  end
  t.filter :after do |prev, time, args, &block|
    prev + time
  end
  "hello" + "other" # => 'helloother1000'
```
## Contributing to tivoli

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 Erik Fonselius. See LICENSE.txt for
further details.

