require "engineering_calculator/version"

module EngineeringCalculator
  class Calculator
    attr_accessor :result

    def initialize(keisan="")
      @result = split_each_calc(keisan)
    end

    def split_each_calc(keisan)
      keisan.delete!(" ")
      result = keisan.split(/([\(\)\+\*\/])|(\d+[^\d\/]+\/[^\d\/]+\d*)|(\^\d*)/)
      result.reject!{ |c| c.empty? }

      result.map! do |elem|
        elem.sub!(/^\^/, "**")
        elem =~ (/(^\d+)/)
        [$1||elem, nil, $1, $']
      end
      #calc(result)
    end

    def calc(result)
      formula = String.new
      result.each { |elem| formula << elem[0] }
      eval(formula)
    end
  end
end
