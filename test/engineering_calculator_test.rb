require "test_helper"

class EngineeringCalculatorTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::EngineeringCalculator::VERSION
  end

  def test_it_does_something_useful
    keisan = ::EngineeringCalculator::Calculator.new("20Mpa + 10Mpa =")
    assert_equal keisan.result, ["20Mpa+", "10Mpa="]
  end
end
