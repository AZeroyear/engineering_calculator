require "engineering_calculator/version"
require 'yaml'

module EngineeringCalculator
  class Calculator
    attr_accessor :result
    def initialize(keisan="")
      @arithmetic = /(\^\(?[\+\-]?\d+\/?\d*\)?)|([\(\)\+\-\*\/])/
      @numeric = /\d+(?:\.\d*)?(?:e[+-]?\d+)?/
      @result = split_each_calc(keisan)
    end

    def split_each_calc(keisan)
      keisan.delete!(" ")
      result = keisan.split(/(#{@numeric}(?:[a-z]+\/?[a-z]?\d*)?)|#{@arithmetic}/i)
      result.reject!{ |c| c.empty? }

      result.map! do |elem|
        original = split_unit(elem)
        conv = split_unit(conversion(elem))
        [conv["value"], conv["unit"], original["value"], original["unit"]]
      end

      result
      formula = String.new
      result.each do |elem|
        formula << elem[0].to_s + elem[1].to_s
      end
      kekka = [formula.sub(/(\*\*)/,"^"), calc(result)]
    end

    def calc(result)
      formula = String.new
      result.each { |elem| formula << elem[0] }
      eval(formula)
    end

    def unit_calc(unit = ["m", "+", "m"])
      unit_formula = String.new
      unit.each_with_index do |elem, id|
        if id == 0
          unit_formula << elem
        elsif elem == "+"
          unit_formula

        end
      end
      unit_formula
    end

    def conversion(keisan)
      #SI単位を返す
      vu = split_unit(keisan)

      all_unit = YAML.load_file("lib/unit.yml")
      all_unit.each_value { |type| keisan = (vu["value"].to_f / type[vu["unit"]].to_f ).to_s + type.key(1) if type.key?(vu["unit"]) }
      if keisan =~ /^\^/
        keisan.sub!(/(\/\d+)/) { |match| match + ".0" }
        keisan.sub!(/^\^/, "**")
      end
      keisan
    end

    def split_unit(keisan)
      keisan =~ /(^\*+\(?[\+\-]?\d+.*\)?)|(#{@numeric})|#{@arithmetic}/i
      value = $&
      unit = $'
      hash = Hash.new
      hash = {"value" => value, "unit" => unit}
    end
  end
end
