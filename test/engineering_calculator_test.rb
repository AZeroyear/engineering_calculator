require "test_helper"

class EngineeringCalculatorTest < Minitest::Test

  def test_it_does_something_useful
    keisan = ::EngineeringCalculator::Calculator.new("(100Mpa+30psi)*200Mpa/s/500ton/m3")
    assert_equal keisan.result,
                  [["(",nil,nil,nil],
                  [100,"Mpa",nil,nil],
                  ["+",nil,nil,nil],
                  [30,"psi",nil,nil],
                  [")",nil,nil,nil],
                  ["*",nil,nil,nil],
                  [200,"Mpa/s",nil,nil],
                  ["/",nil,nil,nil],
                  [500,"ton/m3",nil,nil]]
  end
end
