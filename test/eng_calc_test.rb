require "test_helper"

class EngineeringCalculatorTest < Minitest::Test
  def setup
    @eng_calc = Eng::Calc.new
  end

  def test_calc_method
    assert_equal @eng_calc.calc("500*(300/200)"), {:value=>750.0, :unit=>"", :error=>[{}], :si_formula=>"500 *  ( 300 / 200 ) "}
    assert_equal @eng_calc.calc("10cm+20m"),  {:value=>20.1, :unit=>"m", :error=>[{}], :si_formula=>"0.1 (m) + 20.0 (m)"}
    assert_equal @eng_calc.calc("100m/20s"), {:value=>5.0, :unit=>"m/s", :error=>[{}], :si_formula=>"100.0 (m) / 20.0 (s)"}
    assert_equal @eng_calc.calc("1psi"), {:value=>6894.7572931684, :unit=>"kg/(s2*m)", :error=>[{}], :si_formula=>"6894.7572931684 (kg/(m*s2))"}
    assert_equal @eng_calc.calc("10PSI*20s2"), {:value=>1378951.45863368, :unit=>"s2*kg/(s2*m)", :error=>[{:unit_upcase=>"PSI"}, {:unit_not_found=>"s2"}, {}], :si_formula=>"68947.572931684 (kg/(m*s2)) * 20 (s2)"}
    assert_equal @eng_calc.calc("10PSI/20/s"), {:value=>3447.3786465842, :unit=>"kg/(m*s)", :error=>[{:unit_upcase=>"PSI"}, {}], :si_formula=>"68947.572931684 (kg/(m*s2)) / 20.0 (/s)"}
    assert_equal @eng_calc.calc("10PSI/20(/s)"), {:value=>3447.3786465842, :unit=>"kg/(m*s)", :error=>[{:unit_upcase=>"PSI"}, {}], :si_formula=>"68947.572931684 (kg/(m*s2)) / 20.0 ((/s))"}
    assert_equal @eng_calc.calc("1981(kg/s)/2059m"), {:value=>0.9621175327829043, :unit=>"kg/(s*m)", :error=>[{}], :si_formula=>"1981.0 ((kg/s)) / 2059.0 (m)"}
    assert_equal @eng_calc.calc("2cm*300cm/s"),{:value=>0.06, :unit=>"m2/s", :error=>[{}], :si_formula=>"0.02 (m) * 3.0 (m/s)"}
  end

end
