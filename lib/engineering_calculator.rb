require "engineering_calculator/version"
require 'yaml'

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
        original = split_unit(elem)
        conv = split_unit(conversion(elem))
        [conv["value"], conv["unit"], original["value"], original["unit"]]
      end
      formula = String.new
      calc(result)
    end

    def calc(result)
      formula = String.new
      result.each { |elem| formula << elem[0] }
      eval(formula)
    end

    def conversion(keisan)
      #SI単位を返す
      vu = split_unit(keisan)

      all_unit = YAML.load_file("lib/unit.yml")
      all_unit.each_value { |type| keisan = (type[vu["unit"]] * vu["value"].to_i).to_s + type.key(1) if type.key?(vu["unit"]) }
      keisan.sub!(/^\^/, "**") if keisan =~ /^\^/
      keisan
    end

    def unit_conversion(unit)

    end


    def split_unit(keisan)
      keisan =~ /(^\*+\d+)|([\(\)\+\*\/])|(\d+.*\d)|(^\^\d+)/
      value = $&
      unit = $'
      hash = Hash.new
      hash = {"value" => value, "unit" => unit}
    end
  end
end

=begin
    def formula
      root()
      sqrt()
      _/()

      ^
      **

    end
=end
