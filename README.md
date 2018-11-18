# EngineeringCalculator

### a. 使い方
calc = EngineeringCalculator.new("100kgg / 20mm2")  
calc.result #=> ["5Mpa","100kgg/20mm2"]  
calc.calc("10mpa + 20psi")  
calc.result #=> ["30Mpa","10Mpa+20Mpa"]  
calc.evaluate("100mpa +10m") #=> fail  

### b. 実装計画
#### 1) 数式を取り出す
  1. (), \*, / を評価して配列に代入
  ~~~
  100kg / 20mm2 + 10psi #=> [100kg/20mm2,+,10psi,=]  

  ex: (100kgg + 10pondg) / 20kg/mm2 + 10psi #=> [100kgg+ 10pondg,/,20mm2,+,10psi,=]  
  ~~~
  2. 
  2. 配列に変換
  ~~~
  [[数式,数値,単位]]
  ~~~
#### 2) Validate?メソッドで単位の並びを評価
  1. 単位評価  
  +, - で同じカテゴリーに属していない単位が選択されていたらFailを返して終了。  
  ~~~
  Mpa + psi => true  
  Mpa * Mpa/s => true  
  Mpa + m => fail  
  Mpa + kg => fail  
  ~~~

  2. 計算式評価  
  ()の数が間違っている。一番最後の)抜きはOK。  
  ~~~
  ((100kg/20m2 + 20psi) + 20 => true  
  (20+10) * 100mpa) => fail  
  ~~~
  //, ** など計算式が連続している。  

  3. 単位抜き  


#### 3) 単位換算
  1. メモ書き  
  \*,/は単位無しの倍数とみなす。  
  ~~~
  100 * 20mpa #=> 20000Mpa  
  ~~~
  +,-並びに記載されているもので単位が一つしかない時は、その単位とする。  
  ~~~
  100 + 20psi => 100Mpa + 20psi  
  ~~~
  2. 単位換算表(yml形式)  


#### 4) 数値計算
  1. 数式だけを取り出す  
  2. evalを使用して計算する  

#### 5) 単位計算
  1. 単位を計算するメソッドの用意


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
