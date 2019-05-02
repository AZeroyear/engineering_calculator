require "test_helper"

class EngineeringCalculatorTest < Minitest::Test
  def setup
    @eng_calc = Engineer::Calculator.new
  end
  def test_calc_method
    assert_equal @eng_calc.calc("500*(300/200)"), {:value=>"750", :unit=>"", :convert_formula=>"500* ( 300/ 200)  "}
    assert_equal @eng_calc.calc("10cm+20m"),  {:value=>"20.1", :unit=>"m", :convert_formula=>"0.1(m)+ 20(m) "}
    assert_equal @eng_calc.calc("100m/20s"), {:value=>"5", :unit=>"m/s", :convert_formula=>"100(m)/ 20(s) "}
    assert_equal @eng_calc.calc("1psi"), {:value=>"6894.8", :unit=>"kg/(m*s2)", :convert_formula=>"6894.8(kg/(m*s2)) "}
    assert_equal @eng_calc.calc("10PSI*20s2"), {:value=>"1.379e+06", :unit=>"kg/m", :convert_formula=>"68948(kg/(m*s2))* 20(s2) "}
    assert_equal @eng_calc.calc("10PSI/20/s"), {:value=>"3447.4", :unit=>"kg/(m*s)", :convert_formula=>"68948(kg/(m*s2))/ 20(/s) "}
    assert_equal @eng_calc.calc("10PSI/20(/s)"), {:value=>"3447.4", :unit=>"kg/(m*s)", :convert_formula=>"68948(kg/(m*s2))/ 20((/s)) "}
    assert_equal @eng_calc.calc("1981(kg/s)/2059m"), {:value=>"0.96212", :unit=>"kg/(s*m)", :convert_formula=>"1981((kg/s))/ 2059(m) "}
    assert_equal @eng_calc.calc("2cm*300cm/s"), {:value=>"0.06", :unit=>"m2/s", :convert_formula=>"0.02(m)* 3(m/s) "}
  end

  def test_convert_to_si_unit
    assert_equal @eng_calc.convert("psi"), [6894.757293168324, ["kg", "/", "(", "m", "*", "s2", ")"]]
    assert_equal @eng_calc.convert("PSI"), [6894.757293168324, ["kg", "/", "(", "m", "*", "s2", ")"]]
    assert_equal @eng_calc.convert("kPa"), [10e2, ["kg", "/", "(", "m", "*", "s2", ")"]]

  end

  def test_convert_metrix
    assert_equal @eng_calc.convert_metric("T"), "10e11"
  end

  def test_calc_unit
    assert_equal @eng_calc.calc_unit(%w|m * m|), "m2"
    assert_equal @eng_calc.calc_unit(%w|( m / s * s )|), "m"
    assert_equal @eng_calc.calc_unit(%w|( kg / ( kg * m ) )|), "/m"
  end

  def test_parenthesis_unit
    assert_equal @eng_calc.parenthesis_unit(%w|( kg / ( m * s ) )|), [[0, 8], [0, 8], [3, 7]]
  end

  def test_split_si_unit
    assert_equal @eng_calc.split_si_unit("m/s"), [1.0, ["m","/","s"]]
    assert_equal @eng_calc.split_si_unit("s-2"), [1.0, ["s-2"]]
  end

  def split_unit
    assert_equal @eng_calc.split_unit("20mpa"), [{:value=>"20", :unit=>"mpa"}]
    assert_equal @eng_calc.split_unit("500m/20(/s)"), [{:value=>"500", :unit=>"m"}, {:value=>"/", :unit=>"/"}, {:value=>"20", :unit=>"(/s)"}]
  end
end
