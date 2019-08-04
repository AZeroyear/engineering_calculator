require 'yaml'
require_relative 'eng_formula'
require_relative 'eng_unit_calc'

module Eng
  module ExtensionClass
    include Eng
    refine Hash do
      def to_names
        case self
        when Unit.variable
          self.inject([]) do |a, k|
            a << k[1].keys.inject([]) { |arr, key| arr << key.split(", ") }.flatten
          end.flatten
        when  Unit.si_alter
          self.inject([]) { |a, v| a << v }.flatten
        when Unit.metric_prefix
          self.keys
        when Unit.si_base
          self.values
        end
      end

      def to_find(unit_name)
        case self
        when Unit.si_base, Unit.si_derived
          return {formula: "value", kind: self.key(unit_name)} if self.key(unit_name)
        when Unit.si_alter
          self.each do |kind, units|
            return {formula: "value", kind: kind} if units.include?(unit_name)
          end
        when Unit.variable
          self.each do |kind_unit|
            kind_unit[1].each do |unit, value|
              return {formula: value, kind: kind_unit[0]} if unit.split(", ").include?(unit_name)
            end
          end
        end
        nil
      end

      def to_reg
        Regexp.new(self.to_names.sort{ |a,b| b.size <=> a.size }.map{|x| Regexp.escape(x)}.join("|"))
      end
    end

    refine Object do
      def send(name, *args)
        return self unless name
        super
      end
    end
  end

  module Unit
    include Formula
    attr_accessor :opt

    def convert(value: , unit: )
      values = nil
      first_unit = false
      convert_unit = split_by_ari(unit).map do |e_unit|
        if e_unit.empty?
        elsif e_unit =~ /(#{operator_reg(:ari)})/
          values = e_unit
          if e_unit == "/" && !first_unit
            values = value.to_s + "/"
            first_unit = true
          end
          { value: values, unit: e_unit }
        else
          values = first_unit ? 1 : value
          first_unit = true
          Unit.convert_to_si(value: values.to_f.rationalize, unit: e_unit)
        end
      end
      results = convert_unit.compact.inject({ value: "", unit: [], error: [] }) do |result, convert|
        result[:value] << convert[:value].to_s
        result[:unit]  << split_by_ari(convert[:unit]) if convert[:unit]
        result[:error] << convert[:error] if convert[:error]
        result
      end
      results[:value] = eval(results[:value] << "")
      results[:unit].flatten!.reject!(&:empty?)
      results
    end

    class << self
      include Formula
      include UnitCalc
      using ExtensionClass
      def si_base
        @si_base_unit ||= YAML.load_file(File.join(__dir__, 'unit_calc/si_base_unit.yml'))
        return @si_base_unit.inject({}){ |h, (k,v)| h[k] = v.upcase; h } if @opt
        @si_base_unit
      end

      def si_derived
        @si_derived_unit ||= YAML.load_file(File.join(__dir__, 'unit_calc/si_derived_unit.yml'))
        return @si_derived_unit.inject({}){ |h, (k,v)| h[k] = v.upcase; h } if @opt
        @si_derived_unit
      end

      def variable
        @variable_unit ||= YAML.load_file(File.join(__dir__, 'unit_calc/variable_unit.yml'))
        return @variable_unit.inject({}){ |h, (k,v)| h[k] = v.inject({}){ |hh, (kk, vv)| hh[kk.upcase] = vv; hh }; h } if @opt
        @variable_unit
      end

      def metric_prefix
        @metric_prefix ||= YAML.load_file(File.join(__dir__, 'unit_calc/metric_prefix.yml'))
        return @metric_prefix.inject({}){ |h, (k,v)| h[k.upcase] = v; h } if @opt
        @metric_prefix
      end

      def si_alter
        @si_alter_unit ||= YAML.load_file(File.join(__dir__, 'unit_calc/si_alter_unit.yml'))
        return @si_alter_unit.inject({}){ |h, (k,v)| h[k] = v.inject([]){ |a, aa| a << aa.upcase; a }; h } if @opt
        @si_alter_unit
      end

      def find_all(unit)
        [:si_base, :si_alter, :si_derived, :variable].each do |method|
          result = Unit.send(method).to_find(unit)
          return result if result
        end
        nil
      end

      def convert_to_si(value: , unit: , opt: nil)
        value = value.rationalize
        metric = nil
        num = 1
        @opt = opt
        original_unit = unit
        unit = unit.send(opt)
        if unit.match(to_si_reg) do |si_unit|
            break if si_unit[0] != unit || si_unit[0].upcase == "KG"
            metric = si_unit[:metric]
            unit = si_unit[:si] + (si_unit[:num] || "")
            num = si_unit[:num] || 1
          end
        end

        result = find_all(unit)

        if !result && !opt
          convert_to_si(value: value, unit: unit, opt: :upcase)
        elsif result
          @opt = nil
          metric = metric ? (metric_prefix[original_unit[0]].to_f ** num.to_f).rationalize : 1
          {
            value: eval(result[:formula].to_s + "*#{metric}").to_f,
            unit: to_si(result[:kind]),
            kind: result[:kind],
            error: opt ? { unit_upcase: original_unit } : nil
          }
        else
          {
            value: value,
            unit: original_unit,
            kind: nil,
            error: original_unit.empty? ? nil : { unit_not_found: original_unit }
          }
        end
      end

      def kind_by_si(unit)
        s_unit = unit_arrange(split_by_ari(unit))
        si_base.merge(si_derived).each do |e_unit|
          return e_unit[0] if s_unit == unit_arrange(split_by_ari(e_unit[1]))
        end
        false
      end

      def to_si(kind_unit)
        si_base[kind_unit] || si_derived[kind_unit]
      end

      def to_si_reg
        /((?<metric>#{metric_prefix.to_reg})(?<si>#{si_base.to_reg}|g){1}(?<num>-*\d)*)|((?<metric>#{metric_prefix.to_reg})(?<si>#{si_alter.to_reg}))/
      end

      def unit_reg
        /(#{si_derived.to_reg})|((?:#{metric_prefix.to_reg})?#{si_alter.to_reg})|(#{variable.to_reg})|((?:#{metric_prefix.to_reg})?(?:#{si_base.to_reg}|g){1}-*\d*)|(#{operator_reg(:ari)})/
      end

      def variable_names
        variable.inject({}) do |a, k|
          a[k[0]] = k[1].keys.join(", ").split(", ")
          a
        end
      end
    end
  end
end
