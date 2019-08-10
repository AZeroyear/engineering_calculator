module Eng
  module Formula
    def split_value_unit(formula)
      unit_array = []
      formula_pre = formula.to_s.delete(" ")
      formula_pre.scan(/(#{operator_reg(:tri)})|
                      (?:(#{operator_reg(:num)}(?:#{operator_reg(:double)})*)([^#{operator_reg(:num)}#{operator_reg(:double)}#{operator_reg(:ari)}]+))|
                      (?:(#{operator_reg(:num)}(?:#{operator_reg(:double)})*)((?:\/?\(?\/?[a-z]+\d*(?:\*[a-z])*(?:\W*[a-z]\d*\)*)*)(?:\d[^[a-z]])*\)?))|
                      (#{operator_reg(:ari)})|
                      ((?:#{operator_reg(:num)})*(?:#{operator_reg(:double)})?)/ix)
                      .each do |data|
                        unit_array << {
                          value: (data[0] || data[3] || data[5] || data[6] || data[1]),
                          unit: (data[4] || data[5]) || data[2] }
      end

      unit_array.each_with_index do |data, index|
        if data[:unit] =~ /^[^\(]+\)$/
          data[:unit].gsub!(/.$/,'')
          unit_array.insert(index+1, { value: ")", unit: ")" })
        end
      end
      unit_array.delete_if{ |data| true if data[:value].empty? && data[:unit].nil? }
    end

    def operator_reg(kind_operator)
      case kind_operator
      when :ari
        /(?:[\(\)\+\-\*\/])/
      when :double #２乗表現のマッチング (2^1/2)
        /(?:\^\(?[\+\-]?\d+\/?\d*\)?)/
      when :num
        /\d+(?:\.\d*)?(?:e[+-]?\d+)?/
      when :tri
        /(?:sin|cos|tan)\(.+\)/
      end
    end

    def split_by_ari(formula)
      formula.split((/(#{operator_reg(:ari)})/)).reject(&:empty?)
    end

    def liner_function(formula)
      formula_arr = formula.split(/(\*|\/|\+|-)/)
      input_num = formula_arr.index("value")
      mv_num = formula_arr.index{ |n| n =~ /\*|\// }
      pm_num = formula_arr.index{ |n| n =~ /\+|-/ }

      if mv_num
        a_ari = formula_arr[mv_num]
        if input_num > mv_num
          a = formula_arr[mv_num - 1]
        else
          a = formula_arr[mv_num + 1]
        end
      else
        a_ari = "/"
        a = 1
      end

      if pm_num
        b_ari = formula_arr[pm_num]
        if input_num > pm_num
          b = formula_arr[pm_num - 1]
        else
          b = formula_arr[pm_num + 1]
        end
      else
        b_ari = "+"
        b = 0
      end

      a_ari == "*" ? a_ari = "/" : a_ari = "*"
      b_ari == "+" ? b_ari = "-" : b_ari = "+"

      "value" + a_ari + a.to_s + b_ari + b.to_s + a_ari + a.to_s
    end

    def new_liner_function(formula)
      fl_arr = formula.split(/(\*|\/|\+|-)/)
      value_i = fl_arr.index("value")

      a = []
      b = []
      pl = false
      (value_i .. fl_arr.size - 1).each do |i|
        if pl || fl_arr[i] == "+" || fl_arr[i] == "-"
          b << reverse_operator(fl_arr[i])
          pl = true
        else
          a << reverse_operator(fl_arr[i])
        end
      end

      if value_i != 0
        (0 .. value_i - 1).reverse_each do |i|
          if fl_arr[i] == "+" || fl_arr[i] == "-" || i == 0
            (i .. value_i - 1).reverse_each do |ii|
              a.unshift(reverse_operator(fl_arr[ii]))
            end

            if i != 0
              (0..i).each do |ii|
                b.unshift(reverse_operator(fl_arr[ii], false))
              end
            end
            break
          end
        end
      end
      a.join + "+(" + b.join + ")/value"
    end

    def reverse_operator(operator, opt = true)
      case operator
      when "+"
        "-"
      when "-"
        "+"
      when "*"
        opt ? "/" : "*"
      when "/"
        opt ? "*" : "/"
      else
        operator
      end
    end
  end
end
