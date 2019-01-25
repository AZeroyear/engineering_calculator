#require "engineering_calculator/version"
require 'yaml'

module Engineer
  class Calculator
    include Math
    attr_reader :error, :alter
    def initialize
      @error = {}
      @alter = {}
    end

    def calc(formula)
      @error = {}
      #begin
        formula = split_unit(formula.gsub("⋅","*")).compact
        formula.map! do |each_formula|
          if each_formula[:value] =~ /#{reg(:ari)}/
            [each_formula[:value], [each_formula[:value]]]
          elsif each_formula[:unit].empty?
            [each_formula[:value], nil]
          else
            each_formula[:unit]
            convert_value = si_unit(each_formula[:unit])
            [each_formula[:value].to_f * convert_value[0].to_f, convert_value[1].unshift("(").push(")")]
          end
        end
        value = String.new
        units = []
        formula.each do |x|
          value << x[0].to_s + (x[0].to_s =~ reg(:ari) ? "" : ".rationalize")
          units << x[1]
        end
        return [eval(value), units.flatten.join, formula.join] unless @error[:unit_not_found].nil?
        [sprintf("%.05g", eval(value)), calc_unit(units.flatten), formula.inject(String.new){|f, v| f << v[0].to_s + (v[0] != v[1].join ? v[1].join : "")}]
      #rescue
      #  "Sorry, we could not calculate"
      #end
    end

    def si_unit(units)
      unit = units.scan(unit_reg)
      unless unit.each { |each_unit| break false unless each_unit[4].nil? }
        opt = :upper
        unit = units.upcase.scan(unit_reg(opt))
      end

      unit.map! do |each_unit|
        if each_unit[4]
          @error[:unit_not_found] ||= [" could not be found"]
          @error[:unit_not_found].unshift(units)
          return [1, [units]]
        elsif each_unit[0] #alter
          keisan = convert_to_si_unit_from_alter(each_unit[0],opt)
          keisan[1] = split_si_unit keisan[1]
          [keisan[0]*keisan[1][0], keisan[1][1]]
        elsif each_unit[1] #variable_unit
          keisan = convert_to_si_unit_from_variable(each_unit[1])
          keisan[1] = split_si_unit(keisan[1])
          [keisan[1][0]/keisan[0], keisan[1][1]]
        elsif each_unit[2] #si_unit
          split_si_unit each_unit[2], opt
        elsif each_unit[3] #演算子
          [each_unit[3], each_unit[3]]
        end
      end

      value = String.new
      unit_si = []
      unit.each do |each_unit|
        value << each_unit[0].to_s
        unit_si << each_unit[1]
      end
      value.gsub!(/^\//,"1/")
      value.gsub!(/^\(\//,"(1/")
      [eval(value), unit_si.flatten]
    end

    def calc_unit(units) #配列で単位を受け取る。
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
      search_unit units
      unit_arrange units
    end

    def unit_arrange(units)
      pos = []
      neg = []
      units.each do |unit|
        num = unit.match(/(?<base>#{reg(:base)}){1}(?<num>-*\d*)/)
        if num[:num].nil? || num[:num].to_i.positive?
          number = num[:num].to_i == 1 ? nil : num[:num]
          pos << num[:base] + number.to_s
        else
          number = num[:num].to_i == -1 ? nil : - (num[:num].to_i)
          neg << num[:base] + number.to_s
        end
      end
      div = neg.size > 1 ? ("/" + "(" + neg.join("*") + ")") : (neg.empty? ? nil : "/" + neg.join.to_s)
      pos.join("*") + div.to_s
    end

    def search_unit(units)
      si_base_unit.merge(si_derived_unit).each do |key, value|
        break @alter = key if multi_div_unit(split_si_unit(value)[1]).sort == multi_div_unit(units).sort
      end
    end

    def plus_minus_unit(array)
      array.each_with_index do |value, i|
        unless i == 0 || (array[i-1].sort == array[i].sort)
          @error[:plus_minus] ||= ["is different unit. Plus minus is imposshible"]
          @error[:plus_minus].unshift "#{array[i-1].join} + #{array[i].join}"
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
        num = unit.match(/(?<base>#{reg(:base)}){1}(?<num>-*\d*)/)
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
          base = num[:base]
          num = num[:num].empty? ? 1 : num[:num]
          unit_hash[base] = eval(unit_hash[base].to_s + ari + num.to_s)
          ari = "+" unless end_par == "-"
        end
      end
      unit_hash.sort{|a,b| b[1] <=> a[1]}.map { |key, value| value == 0 ? nil : key + value.to_s}.compact
    end

    def parenthesis_unit(formula) #formulaは配列で入ってくる。["m","/","s"]
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

    def split_si_unit(si_unit, opt=nil)
      unit = si_unit.split(/([\*\/\(\)])/).reject(&:empty?).map do |s_unit|
        s_unit =~ /([\*\/\(\)])/ ? s_unit : extraction_metric(s_unit, opt)
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
      [eval(value.gsub(/^(#{reg(:ari)})/,"")), unit_si]
    end

    def extraction_metric(si_unit, opt = nil)
      unit = {}
      si_unit.upcase! if opt
      si_unit.match(/(?<metric>#{reg(:metric, opt)})?(?<base>(#{reg(:base, opt)}|g){1})(?<numeric>-*\d)*/) do |sp_unit|
        sp_unit[0]
        unit[:original] = sp_unit[0]
        unit[:metric] = opt ? metric_prefix_unit.each_key { |metric| break metric if sp_unit[:metric].upcase == metric.upcase } : sp_unit[:metric]
        unit[:base] = opt ? si_base_unit.each_value { |b_unit| break b_unit if b_unit.upcase == sp_unit[:base].upcase } : sp_unit[:base]
        unit[:numeric] = sp_unit[:numeric] || nil
      end
      metric = if unit[:base] == "g"
        unit_base = "kg"
        convert_metric_weight(unit[:metric])
      else
        unit[:metric] ? convert_metric(unit[:metric]).to_f.rationalize**(unit[:numeric] || 1).rationalize : 1
      end
      [metric.to_f, unit_base || unit[:base] + unit[:numeric].to_s]
    end

    def convert_metric(metric)
      metric_prefix_unit[metric]
    end

    def convert_metric_weight(weight_metric)
      convert_metric(weight_metric).to_f / convert_metric("k").to_f
    end

    def convert_to_si_unit_from_variable(unit)
      variable_unit.each do |kind, v_unit|
        return [v_unit[unit], si_base_unit.merge(si_derived_unit)[kind]] if v_unit.key?(unit)
        v_unit.each do |v_unit_name, value|
          return [value, si_base_unit.merge(si_derived_unit)[kind]] if v_unit_name.upcase == unit.upcase
        end
      end
    end

    def convert_to_si_unit_from_alter(alter_unit, opt = nil)
      unit = {}
      alter_unit.match(/(?<metric>#{reg(:metric, opt)})?(?<alter>#{reg(:alter, opt)})/) do |si_unit|
        unit[:metric] = si_unit[:metric] ? metric_prefix_unit.each { |m_unit, value| break m_unit if si_unit[:metric].upcase == m_unit.upcase } : nil
        unit[:alter] = opt ? si_alter_unit.each { |kind, a_unit| break a_unit[0] if si_unit[:alter].upcase == a_unit[0].upcase } : si_unit[:alter]
      end
      si_alter_unit.each do |key, value|
        break [convert_metric(unit[:metric]) || 1, si_base_unit.merge(si_derived_unit)[key]] if value.include?(unit[:alter])
      end
    end
  #private
    def split_unit(formula)
      unit_array = []
      formula_pre = formula.to_s.delete(" ")
      formula_pre.scan(/(#{reg(:tri)})|(?:(#{reg(:num)})((?:\/?\(?\/?[a-z]+(?:\*[a-z])*(?:\W*[a-z]\d*\)*)*)-*\d*\)?))|(#{reg(:ari)})/i).each do |data|
        unit_array << { value: (data[0] || data[1] || data[3]), unit: (data[2] || data[3]) }
      end
      unit_array
    end

    def si_base_unit
      @si_base_unit ||= YAML.load_file(File.join(__dir__, 'si_base_unit.yml'))
    end

    def si_derived_unit
      @si_derived_unit ||= YAML.load_file(File.join(__dir__, 'si_derived_unit.yml'))
    end

    def variable_unit
      @variable_unit ||= YAML.load_file(File.join(__dir__, 'variable_unit.yml'))
    end

    def metric_prefix_unit
      @metric_prefix ||= YAML.load_file(File.join(__dir__, 'metric_prefix.yml'))
    end

    def si_alter_unit
      @si_alter_unit ||= YAML.load_file(File.join(__dir__, 'si_alter_unit.yml'))
    end

    def reg(kind_of_unit, opt = nil)
      case kind_of_unit
      when :ari
        /(?:\^\(?[\+\-]?\d+\/?\d*\)?)|(?:[\(\)\+\-\*\/])/
      when :num
        /\d+(?:\.\d*)?(?:e[+-]?\d+)?/
      when :tri
        /(?:sin|cos|tan)\(.+\)/
      else
        hash_name = self.methods.grep(/.*#{kind_of_unit.to_s}.*(_unit)$/).first.to_s
        unit_hash = if hash_name.include?("variable")
            hash = {}
            send(hash_name).values.each{|x| hash.merge!(x)}.flatten
            hash
          else
            send hash_name
          end
        keys_or_values = hash_name.to_s.include?("si") ? :values : :keys

        if opt == :upper
          Regexp.new("#{unit_hash.send(keys_or_values).flatten.sort{|a,b| b.size <=> a.size}.map{|x| "|#{Regexp.escape(x)}"}.join.upcase}".gsub(/^\|/,""))
        else
          Regexp.new("#{unit_hash.send(keys_or_values).flatten.sort{|a,b| b.size <=> a.size}.map{|x| "|#{Regexp.escape(x)}"}.join}".gsub(/^\|/,""))
        end
      end
    end

    def unit_reg(opt = nil)
      /((?:#{reg(:metric, opt)})?#{reg(:alter, opt)})|(#{reg(:variable, opt)})|((?:#{reg(:metric, opt)})?(?:#{reg(:base, opt)}|g){1}-*\d*)|(#{reg(:ari)})|(.)/
    end

  end
end
