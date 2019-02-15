require "test_helper"

class EngineeringCalculatorTest < Minitest::Test
  def setup
    @eng_calc = Engineer::Calculator.new
  end
  def test_calc_method
    assert_equal @eng_calc.calc("500*(300/200)"), ["750", "", "500*(300/200)"]
    assert_equal @eng_calc.calc("10cm+20m"), ["20.1", "m", "0.1(m)+20.0(m)"]
    assert_equal @eng_calc.calc("100m/20s"), ["5", "m/s", "100.0(m)/20.0(s)"]
    assert_equal @eng_calc.calc("1psi"), ["6894", "kg/(m*s2)", "6894.0(kg/(m*s2))"]
    assert_equal @eng_calc.calc("10PSI*20s2"), ["1.3788e+06", "kg/m", "68940.0(kg/(m*s2))*20.0(s2)"]
    assert_equal @eng_calc.calc("10PSI/20/s"), ["3447", "kg/(m*s)", "68940.0(kg/(m*s2))/20.0(/s)"]
    assert_equal @eng_calc.calc("10PSI/20(/s)"), ["3447", "kg/(m*s)", "68940.0(kg/(m*s2))/20.0((/s))"]
    assert_equal @eng_calc.calc("1981(kg/s)/2059m"), ["0.96212", "kg/(s*m)", "1981.0((kg/s))/2059.0(m)"]
    assert_equal @eng_calc.calc("2cm*300cm/s"), ["0.06", "m2/s", "0.02(m)*3.0(m/s)"]
  end

  def test_convert_to_si_unit
    assert_equal @eng_calc.convert("psi"), [6894.0, ["kg", "/", "(", "m", "*", "s2", ")"]]
    assert_equal @eng_calc.convert("PSI"), [6894.0, ["kg", "/", "(", "m", "*", "s2", ")"]]
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
