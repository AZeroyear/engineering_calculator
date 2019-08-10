# Engineer Calculator

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'eng_calc'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install engineering_calculator

For web site of calculator, please visit following link.
https://eng.eastazy.work/calculator

### How to use

If your current directory is engineer_calcululator gem,
please run "Rackup". Then access to http://localhost:9292/ , you can find web page.

Add following into your code.
```ruby
require 'eng_calc'
```

Then make instance.

```ruby
eng_calc = Eng::Calc.new
```

After make instance you can get calculation reulst by "calc" method.
Conversion always perform by SI base unit.
```ruby
eng_calc.calc("10cm+20m")
=> {:value=>"20.1", :unit=>"m", :convert_formula=>"0.1(m)+ 20(m) "}
```

After calc method, you can get alter unit result by "alter" method.
```ruby
eng_calc.alter
=> {:si_unit=>[["Length", nil]],
  :variable=>[["Length",
    [["Å", 201000000000.0],
    ["mil", 791338.5826771759],
    ["in", 791.3385826771759],
    ["ft", 65.94488188976331],
    ["yd", 21.98162729658777], ...]]]}
```

If conversion has any error, you can get error message by "error" method.
```ruby
eng_calc.error
=> {}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/engineering_calculator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EngineeringCalculator project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/engineering_calculator/blob/master/CODE_OF_CONDUCT.md).
