require 'minitest/autorun'
require_relative 'HW2_part1'

class TestCalculator < MiniTest::Test
  def setup
    @calculator = Calculator.new('1 + 1')
  end

  def test_char
    #assert true if the given input is a single string character
    assert @calculator.char?('+')
    assert @calculator.char?('.')
    assert @calculator.char?('1')
    refute @calculator.char?('1.1')
    refute @calculator.char?('')
    refute @calculator.char?(nil)
    refute @calculator.char?(1)
  end

  def test_operator
    #assert true if given input is a legal operator
    assert @calculator.operator?('+')
    assert @calculator.operator?(')')
    refute @calculator.operator?('1')
    refute @calculator.operator?('')
    refute @calculator.operator?('+-')
  end

  def test_digits
    #assert true if given input is one of '1234567890.' (char)
    assert @calculator.digits?('1')
    assert @calculator.digits?('.')
    refute @calculator.digits?('+')
    refute @calculator.digits?('')
    refute @calculator.digits?(1)
  end

  def test_numeric
    #assert true if given input is of class Numeric
    assert @calculator.numeric?(1.1)
    assert @calculator.numeric?(-2)
    assert @calculator.numeric?(0)
    refute @calculator.numeric?('1')
    refute @calculator.numeric?(nil)
    refute @calculator.numeric?([1])
  end

  def test_find_num_len
    #find the length of a string segment that is a number
    assert_equal 1, @calculator.find_num_len("1+1.0", 0)
    assert_equal 3, @calculator.find_num_len("1+1.0", 2) #position 2 is the start of '1.0', return 3
    assert_equal 0, @calculator.find_num_len("1+1.0", 1) #position 1 is '+', not a number, return 0
    #the second argument must be integer
    assert_raises RuntimeError do
      @calculator.find_num_len("1+1.0", 1.1)
    end
    #the first argument must be a string
    assert_raises RuntimeError do
      @calculator.find_num_len(1 + 1.0, 0)
    end
  end

  def test_read_expression
    #parse expression string and convert to a list of operators and operands
    assert_equal 0, @calculator.read_expression("1 + 1.0") <=> [1.0, '+', 1.0]
    assert_equal 0, @calculator.read_expression("1") <=> [1]
    assert_equal 0, @calculator.read_expression("1 / (2 - 1)") <=> [1, '/', '(', 2, '-', 1, ')']
  end

  def test_switch_expression
    #switch expression
    assert_equal 0, @calculator.switch_expression([1.0, '+', 1.0]) <=> [1.0, 1.0, '+']
    assert_equal 0, @calculator.switch_expression([1]) <=> [1]
    assert_equal 0, @calculator.switch_expression([1, '/', '(', 2, '-', 1, ')']) <=> [1.0, 2.0, 1.0, "-", "/"]
  end

  def test_operation
    #do element operations, such as 1 + 1 = 2
    assert_equal 2, (@calculator.operation 1, 1, '+')
    assert_equal Float::INFINITY, (@calculator.operation 1, 0, '/') # 1 / 0 = infinity
    assert_equal -1 * Float::INFINITY, (@calculator.operation -3, 0, '/') # -3 / 0 = negative infinity
  end

  def test_calculate
    #do final calculations
    assert_equal 2, (@calculator.calculate [1, 1, '+'])
    assert_equal 1, (@calculator.calculate [1, 2, 1, "-", "/"]) #1 / (2 - 1) = 1
    assert_equal Float::INFINITY, (@calculator.calculate [1, 0, '/'])
  end
end