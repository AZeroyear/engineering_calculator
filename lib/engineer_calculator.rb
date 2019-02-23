#require "engineering_calculator/version"
require 'yaml'

module Engineer
  class Calculator
    include Math
    attr_accessor :error, :alter
    def initialize
      @error = {}
      @opt = nil
    end

    def calc(formula)
      return nil unless formula
      @error = {}
      @result = {}
      @alter = nil
      begin
        formula = split_unit(formula.gsub("⋅","*")).compact
        formula.map! do |each_formula|
          if each_formula[:unit].nil?
            [each_formula[:value], []]
          elsif each_formula[:value] =~ /#{reg(:ari)}/
            [each_formula[:value], [each_formula[:value]]]
          else
            each_formula[:unit]
            convert_value = convert(each_formula[:unit])
            [sprintf("%.05g", each_formula[:value].to_f * convert_value[0].to_f), convert_value[1].unshift("(").push(")")]
          end
        end
        value = String.new
        units = []
        formula.each do |x|
          value << x[0].to_s.sub("^","**") + (x[0].to_s =~ Regexp.union(reg(:ari),/(?:#{reg(:num)})*(?:#{reg(:double)})+/) ? "" : ".rationalize") unless x[0].empty?
          units << x[1]
        end
        @opt = nil
        return @result = { value: eval(value).to_f, unit: units.flatten.join, convert_formula: formula.join } unless @error[:unit_not_found].nil?
        converted_formula = formula.inject(String.new){ |f, v| f << v[0].to_s + (v[0] != v[1].join ? v[1].join : "") }
        @result = { value: sprintf("%.05g", eval(value).to_f), unit: calc_unit(units.flatten), convert_formula: converted_formula }
        @alter = search_unit(@result)
        @result
      rescue StandardError, SyntaxError
        @error[:inapprehensible] = "Sorry, we could not calculate"
        nil
      end
    end

    def convert(units)
      unit = {value: String.new, unit: []}
      convert_unit = try_split_each_unit(units).map { |unit|
        return [1, [units]] unless @error[:unit_not_found].nil?
        convert_to_si_unit(unit)
      }.map do |c_value, c_unit, c_type|
        if c_type
          unit[:value] << c_unit
          unit[:unit] << c_unit
        else
          unit[:value] << "(" + c_value.to_s + "*"
          si_unit = split_si_unit(c_unit)
          unit[:value] << si_unit[0].to_s + ")"
          unit[:unit] << si_unit[1]
        end
      end
      [eval(unit[:value].gsub(/\)\(/,")*(")), unit[:unit].flatten]
    end

    def try_split_each_unit(units)
      type = [:base, :alter, :variable, :base, :ari]
      try_method = [
        {reg: proc {/#{unit_reg}/}, case: @opt=nil, type: nil},
        {reg: proc {/#{unit_reg}/}, case: @opt=:upcase, type: nil},
        {reg: proc {/(#{reg(:variable)})/}, case: @opt=:upcase, type: :variable},
      ]
      try_method.each do |try|
        unit = []
        @opt = try[:case]
        app_unit = send_method(units, @opt).scan(try[:reg].call).map do |e_unit|
          e_unit.each_with_index { |a_unit,i| unit.push({(try[:type] || type[i]) => a_unit}) if a_unit }
        end
        next unless app_unit.join == send_method(units, @opt)
        @error[:capitalize] = "upper/lower case shall be follows / 大文字、小文字は使い分けてください" if @opt
        return unit
      end
      @error[:unit_not_found] ||= [" could not be found"]
      @error[:unit_not_found].unshift(units)
      {unit_not_found: units}
    end

    def send_method(str, method=nil)
      method ? str.send(method) : str
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
      unit_arrange units
    end

    def unit_arrange(units)
      pos = []
      neg = []
      units.each do |unit|
        num = unit.match(/(?<base>#{reg(:base)}){1}(?<num>-*\d*)/)
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

    def search_unit(value:, unit:, convert_formula: nil)
      compare_unit = multi_div_unit(split_si_unit(unit)[1]).sort
      all_unit = {si_unit: [], variable: []}
      si_base_unit.merge(si_derived_unit).delete_if { |type, e_unit|
        compare_unit != multi_div_unit(split_si_unit(e_unit)[1]).sort
      }.each do |unit_name, e_unit|
        all_unit[:si_unit] << [unit_name, si_alter_unit[unit_name] ? si_alter_unit[unit_name].join(" : ") : si_base_unit[unit_name] || si_derived_unit[unit_name] ]
        all_unit[:variable] << [unit_name, variable_unit[unit_name] ? variable_unit[unit_name].map { |v_unit, v_value| [v_unit, value.to_f * v_value.to_f] } : nil]
      end
      all_unit
    end

    def plus_minus_unit(array)
      array.each_with_index do |value, i|
        unless i == 0 || (array[i-1].sort == array[i].sort)
          @error[:plus_minus] ||= ["is different unit./ 足し算の単位が違います。"]
          @error[:plus_minus].unshift "#{unit_arrange(array[i-1])} + #{unit_arrange(array[i])}"
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
          num = unit.match(/(?<base>#{reg(:base)}){1}(?<num>-*\d*)/)
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
      [eval(value.gsub(/^(#{reg(:ari)})/,"")), unit_si]
    end

    def extraction_metric(si_unit)
      unit = {}
      si_unit.upcase! if @opt
      si_unit.match(/(?<metric>#{reg(:metric)})?(?<base>(#{reg(:base)}|g){1})(?<numeric>-*\d)*/) do |sp_unit|
        unit[:original] = sp_unit[0]
        unit[:metric] = @opt && sp_unit[:metric] ? metric_prefix_unit.each_key { |metric| break metric if sp_unit[:metric].upcase == metric.upcase } : sp_unit[:metric]
        unit[:base] = @opt ? si_base_unit.each_value { |b_unit| break b_unit if b_unit.upcase == sp_unit[:base].upcase } : sp_unit[:base]
        unit[:numeric] = sp_unit[:numeric] || 1
      end
      metric = if unit[:base] == "g"
        unit_base = "kg"
        convert_metric_weight(unit[:metric])
      else
        unit[:metric] ? convert_metric(unit[:metric]).to_f**(unit[:numeric].to_f || 1) : 1
      end
      [metric.to_f, unit_base || unit[:base] + ( unit[:numeric] != 1 ? unit[:numeric].to_s : "" )]
    end

    def convert_metric(metric)
      metric_prefix_unit[metric]
    end

    def convert_metric_weight(weight_metric)
      convert_metric(weight_metric).to_f / convert_metric("k").to_f
    end

    def convert_to_si_unit(kind_of_unit)
      if kind_of_unit[:alter]
        unit = kind_of_unit[:alter]
        alter_unit = {}
        unit.match(/(?<metric>#{reg(:metric)})?(?<alter>#{reg(:alter)})/) do |si_unit|
          alter_unit[:metric] = si_unit[:metric] ? metric_prefix_unit.each { |m_unit, value| break m_unit if si_unit[:metric].upcase == m_unit.upcase } : nil
          alter_unit[:alter] = @opt ? si_alter_unit.each { |kind, a_unit| break a_unit[0] if si_unit[:alter].upcase == a_unit[0].upcase } : si_unit[:alter]
        end
        si_alter_unit.each do |key, value|
          return [convert_metric(alter_unit[:metric]) || 1, si_base_unit.merge(si_derived_unit)[key]] if value.include?(alter_unit[:alter])
        end
      elsif kind_of_unit[:variable]
        unit = kind_of_unit[:variable]
        variable_unit.each do |kind, v_unit|
          return [1.0/v_unit[unit].to_f, si_base_unit.merge(si_derived_unit)[kind]] if v_unit.key?(unit)
          v_unit.each do |v_unit_name, value|
            return [1.0/value.to_f, si_base_unit.merge(si_derived_unit)[kind]] if v_unit_name.upcase == unit.upcase
          end
        end
      elsif kind_of_unit[:ari]
        [kind_of_unit[:ari], kind_of_unit[:ari], :ari]
      else
        [1, kind_of_unit[:base]]
      end
    end

    def split_unit(formula)
      unit_array = []
      formula_pre = formula.to_s.delete(" ")
      formula_pre.scan(/(#{reg(:tri)})|(?:(#{reg(:num)}(?:#{reg(:double)})*)((?:\/?\(?\/?[a-z]+(?:\*[a-z])*(?:\W*[a-z]\d*\)*)*)-*\d*\)?))|(#{reg(:ari)})|((?:#{reg(:num)})*(?:#{reg(:double)})?)/i).each do |data|
        unit_array << { value: (data[0] || data[1] || data[3] || data[4]), unit: (data[2] || data[3]) }
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

    def reg(kind_of_unit)
      case kind_of_unit
      when :ari
        /(?:[\(\)\+\-\*\/])/
      when :double
        /(?:\^\(?[\+\-]?\d+\/?\d*\)?)/
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

        Regexp.new("#{unit_hash.send(keys_or_values).flatten.sort{|a,b| b.size <=> a.size}.map{|x| "|#{send_method(Regexp.escape(x), @opt)}"}.join}".gsub(/^\|/,""))
      end
    end

    def unit_reg
      /(#{reg(:derived)})|((?:#{reg(:metric)})?#{reg(:alter)})|(#{reg(:variable)})|((?:#{reg(:metric)})?(?:#{reg(:base)}|g){1}-*\d*)|(#{reg(:ari)})/
    end

  end
end
