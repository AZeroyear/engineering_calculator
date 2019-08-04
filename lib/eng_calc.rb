require "engineer_calculator/version"
require 'yaml'
require_relative "eng_unit"
require_relative "eng_unit_calc"
require_relative "eng_formula"

module Eng
  class Calc
    include Math
    include Unit
    include UnitCalc
    include Formula

    attr_accessor :error, :alter
    def calc(formula)

      return nil unless formula

      begin
        c = { value: "", unit: [], si_formula: "", error: [] }

        split_value_unit(formula.gsub("⋅","*")).map do |e_formula|
          if e_formula[:unit].nil?
            c[:value] << e_formula[:value].to_f.to_s + "r"
            c[:si_formula] << e_formula[:value]
          elsif e_formula[:value] =~ /#{operator_reg(:ari)}/
            c[:value] << e_formula[:value]
            c[:unit] << e_formula[:value]
            c[:si_formula] << " " + e_formula[:value] + " "
          else
            result = convert(e_formula)
            result[:value].to_f
            c[:value] << result[:value].to_f.rationalize.to_s + "r"
            c[:unit] << result[:unit].unshift("(").push(")")
            c[:error] << result[:error] unless result[:error].nil? || result[:error].empty?
            c[:si_formula] << result[:value].to_s + " " + result[:unit].join
          end
        end
        c_unit = calc_unit(c[:unit].flatten)
        { value: eval(c[:value]).to_f,
          unit: c_unit[:unit],
          error:  (c[:error] << c_unit[:error]).flatten.compact,
          si_formula: c[:si_formula] }

      rescue StandardError, SyntaxError
        { value: "error", unit: "", error: "undifined formula", si_formula: formula}
      end
    end

    def each_value(value: , si_unit: nil, kind: nil)
      value = value.to_f.rationalize
      kind = Unit.kind_by_si(si_unit) if si_unit
      return false unless kind || Unit.variable[kind]
      results = Unit.variable[kind].map do |unit|
        { unit: unit[0],
          value: eval(liner_function(unit[1])).to_f }
      end
      { kind: kind, result: results }
    end
  end
end
