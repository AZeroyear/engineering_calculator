require "engineering_calculator/version"

module EngineeringCalculator
  class Calculator
    attr_accessor :result

    def initialize(keisan)
      #1. 計算式(+,-,*,/)で文字列を分割して配列に格納

      keisan.delete!(" ")
      @result = split_each_calc(keisan)
    end

    def split_each_calc(keisan)
      result = []
      i = 0
      keisan.scan(/\d+.*?[\+\-\*\=\/][\d\s]/) do |mathced|
        result[i] = mathced
        i += 1
      end
      result
    end
  end
end
