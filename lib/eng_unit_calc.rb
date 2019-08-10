require_relative "eng_formula"

module Eng
  module UnitCalc
    include Formula
    def calc_unit(units)
      @error = {}
      units = split_by_ari(units) unless units.class == Array
      units.push(")").unshift("(")
      par = parenthesis_unit(units)
      par.reverse_each do |index|
        by_value = units[index[0]..index[1]]
        unit = plus_minus_split(by_value)
        unit.map! do |each_unit|
          multi_div_unit each_unit
        end
        unit = plus_minus_unit(unit)
        add = by_value.include?("(") ? 1 : 0
        units[(index[0]+add)..(index[1]-add)] = unit + Array.new(units[(index[0]+add)..(index[1]-add)].size-unit.size)
      end
      units.compact!
      units.reject!{ |x| x =~ /\(|\)/ }
      { unit: unit_arrange(units), error: @error }
    end

    def plus_minus_unit(array)
      array.each_with_index do |value, i|
        unless i == 0 || (array[i-1].sort == array[i].sort)
          @error[:plus_minus] ||= []
          @error[:plus_minus] << "#{unit_arrange(array[i-1])} + #{unit_arrange(array[i])}"
        end
      end
      array[0]
    end

    def plus_minus_split(units)
      if units.any?{|x| x=="+" || x=="-"}
        num = [0]
        array = []
        units.each_with_index { |x, i| num << i if x == "+" || x == "-" }
        num << units.size - 1
        num.each_with_index { |x, i| array << units[num[i-1]..x].reject!{|x| ["+", "-"].include?(x) } unless i==0 }
        array
      else
        [units]
      end
    end

    def multi_div_unit(units)
      unit_hash = Hash.new(0)
      ari = "+"
      end_par = "+"
      units.compact! unless units.nil?
      units.each do |unit|
        case unit
        when "*", "・", "⋅"
          ari = "+" unless end_par == "-"
        when "/"
          ari = "-"
        when "("
          end_par = "-" if ari == "-"
        when ")"
          end_par = "+"
        else
          num = unit.match(/(?<base>\D+){1}(?<num>-*\d*)/)
          base = num[:base]
          num = num[:num].empty? ? 1 : num[:num]
          unit_hash[base] = eval(unit_hash[base].to_s + ari + num.to_s)
          ari = "+" unless end_par == "-"
        end
      end
      unit_hash.sort{|a,b| b[1] <=> a[1]}.map { |key, value| value == 0 ? nil : key + value.to_s }.compact
    end

    def parenthesis_unit(formula) #formula = ["(", "m","/","s", ")"]
      array = []
      count = []
      formula.each_with_index do |value, index|
        case value
        when "("
          array.push [index, nil]
          count << array.size - 1
        when ")"
          array[count.pop][1] = index
        end
      end
      array.unshift([0,formula.size-1])
    end

    def unit_arrange(units)
      pos = []
      neg = []
      units.each do |unit|
        num = unit.match(/(?<base>(?:[a-zA-Z]+))(?<num>-*\d*)/)
        unless num.nil?
          if num[:num].nil? || num[:num].to_i.positive?
            number = num[:num].to_i == 1 ? nil : num[:num]
            pos << num[:base] + number.to_s
          else
            number = num[:num].to_i == -1 ? nil : - (num[:num].to_i)
            neg << num[:base] + number.to_s
          end
        end
      end
      div = neg.size > 1 ? ("/" + "(" + neg.join("*") + ")") : (neg.empty? ? nil : "/" + neg.join.to_s)
      pos.join("*") + div.to_s
    end

    def split_si_unit(si_unit)
      unit = si_unit.split(/([\*\/\(\)])/).reject(&:empty?).map do |s_unit|
        s_unit =~ /([\*\/\(\)])/ ? s_unit : extraction_metric(s_unit)
      end
      value = String.new
      unit_si = []
      unit.each do |each_unit|
        case each_unit
        when Array
          value << each_unit[0].to_s
          unit_si << each_unit[1]
        when String
          value << each_unit.to_s
          unit_si << each_unit
        end
      end
      [eval(value.gsub(/^(#{operator_reg(:ari)})/,"")), unit_si]
    end

  end
end
