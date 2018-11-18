# EngineeringCalculator

機能一覧

. 使い方
calc = EngineeringCalculator.new("100kg / 20mm2")
calc.result #=> 5Mpa
calc.calc("10mpa + 20psi")
calc.result #=> 20mpa
calc.evaluate(100mpa + 10m) #=> Fail

. 実装計画
1) (), \*, / で数式を取り出す
例: 100kg / 20mm2 + 10psi =
[100kg/20m2,+,10psi,=]

例: (100kgg + 10pondg) / 20mm2 + 10psi =
[100kgg + 10pondg,/,20mm2,+,10psi,=]

2) Validate?メソッドで単位の並びを評価
(単位評価)
+, - で同じカテゴリーに属していない単位が選択されていたらFailを返して終了。
Mpa + psi => OK
Mpa * Mpa/s => OK
Mpa + m => NG
Mpa + kg => NG

(計算入力評価)
()の数が間違っている。一番最後の)抜きはOK
((100kg/20m2 + 20psi) + 20 => OK
(20+10) * 100mpa) => NG

3) 単位換算
単位抜き
  +,-並びに評価されているもの
  ex) 100 + 20psi => 100Mpa + 20psi
  \*,/は単位無しの倍数とみなす
  ex) 100 * 20mpa #=> 20000Mpa

4)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'engineering_calculator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install engineering_calculator

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/engineering_calculator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the EngineeringCalculator project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/engineering_calculator/blob/master/CODE_OF_CONDUCT.md).
