require "test_helper"

class EngineeringCalculatorTest < Minitest::Test
  def setup
    @eng_calc = Engineer::Calculator.new
  end
  def test_calc_method
    assert_equal @eng_calc.calc("10cm+20m"), ["20.1", "m", "0.1(m)+20.0(m)"]
    assert_equal @eng_calc.calc("100m/20s"), ["5", "m/s", "100.0(m)/20.0(s)"]
    assert_equal @eng_calc.calc("1psi"), ["6894.8", "kg/(m*s2)", "6894.757293168324(kg/(m*s2))"]
    assert_equal @eng_calc.calc("10PSI*20s2"), ["1.379e+06", "kg/m", "68947.57293168324(kg/(m*s2))*20.0(s2)"]
    assert_equal @eng_calc.calc("10PSI/20/s"), ["3447.4", "kg/(m*s)", "68947.57293168324(kg/(m*s2))/20.0(/s)"]
    assert_equal @eng_calc.calc("10PSI/20(/s)"), ["3447.4", "kg/(m*s)", "68947.57293168324(kg/(m*s2))/20.0((/s))"]
  end

  def test_si_unit_method
    assert_equal  @eng_calc.si_unit("psi"), [6894.757293168324, ["kg", "/", "(", "m", "*", "s2", ")"]]
    assert_equal  @eng_calc.si_unit("kPa"), [1000.0, ["kg", "/", "(", "m", "*", "s2", ")"]]
  end

  def test_convert_to_si_unit
    assert_equal @eng_calc.convert_to_si_unit_from_variable("psi"), [0.00014503773773021, "kg/(m*s2)"]
    assert_equal @eng_calc.convert_to_si_unit_from_variable("PSI"), [0.00014503773773021, "kg/(m*s2)"]
    assert_equal @eng_calc.convert_to_si_unit_from_alter("kPa"), ["10e2", "kg/(m*s2)"]

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

  def test_extraction_metric
    assert_equal @eng_calc.extraction_metric("kK", :upper), [1000, "K"]
    assert_equal @eng_calc.extraction_metric("kg"), [1, "kg"]
    assert_equal @eng_calc.extraction_metric("cm"), [10e-3, "m"]
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
