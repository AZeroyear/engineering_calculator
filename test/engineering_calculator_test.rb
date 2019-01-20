require "test_helper"

class EngineeringCalculatorTest < Minitest::Test
  def setup
    @eng_calc = Engineer::Calculator.new
  end
  def test_calc_method
    assert_equal @eng_calc.calc("10cm+20m"), ["20.1", "m", "0.1(m)+20.0(m)"]
    assert_equal @eng_calc.calc("100m/20s"), ["5", "m/s", "100.0(m)/20.0(s)"]
    assert_equal @eng_calc.calc("1psi"), ["6894.8", "kg/(m*s2)", "6894.757293168324(kg/(m*s2))"]
  end

  def test_uppser_case
    assert_equal @eng_calc.calc("1mpa"), ["10000","kg/(m*s2)","100000kg/(m*s2)"]
  end

  def test_si_unit_method
    assert_equal  @eng_calc.si_unit("psi"), [0.00014503773773021, ["kg", "/", "(", "m", "*", "s2", ")"]]
    assert_equal  @eng_calc.si_unit("kPa"), [1000.0, ["kg", "/", "(", "m", "*", "s2", ")"]]
  end

  def test_convert_to_si_unit
    assert_equal @eng_calc.convert_to_si_unit("psi","variable"), [0.00014503773773021, "kg/(m*s2)"]
    assert_equal @eng_calc.convert_to_si_unit("kPa"), ["10e2", "kg/(m*s2)"]
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
end
