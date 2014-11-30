#HW2 part1 after debugging with minitest. The input and output methods
#are separated out from other methods. The minitest file for this code is
#in HW2_part_1_test.rb
class Calculator
  attr_accessor :in_list, :post_list, :answer

  def initialize (in_string) #It starts the calculator class
    @in_list = Array.new(read_expression in_string)
    @post_list = Array.new(switch_expression(@in_list))
    @answer = calculate @post_list
  end

  #is a single char?
  def char? (char)
    if not char.instance_of?(String)
      false
    elsif char.chomp.size != 1
      false
    else
      true
    end
  end

  def operator?(char)
    unless char? char
      return false
    end
    operators = '()+-*/'
    operators.include?(char) rescue false
  end

  def digits?(char)
    unless char? char
      return false
    end
    digits = '0123456789.'
    digits.include?(char) rescue false
  end

  #1 will return true, '1' will return false
  def numeric?(elem)
    [Float, Fixnum].include? elem.class
    #not elem.instance_of?(Numeric) because the program don't support other types yet
  end

  #for a given input string of expression and a initial index, this method returns the length
  #of the string segment which represents the number starting from string[index]
  #for input ("1+1", 0), it returns 1, for ("1.0+1.0", 0), it returns 3
  def find_num_len(string, index)
    unless string.instance_of? String and index.instance_of? Fixnum
      raise "Input error"
    end
    i = index
    while i < string.length and digits?(string[i]) do
      i += 1
    end
    return i - index
  end

  #transfers an input string of expression to a list of numbers and operators
  def read_expression (in_string)
    unless in_string.instance_of? String
      raise "Input error"
    end
    in_list = []
    in_string = in_string.chomp
    i = 0
    while i < in_string.length do
      if digits?(in_string[i])
        len = find_num_len(in_string, i)
        in_list.push(Float(in_string[i, len]))
        i = i + len
      elsif operator?(in_string[i])
        in_list.push(in_string[i])
        i = i + 1
      else
        i = i + 1
      end
    end
    return in_list
    ## How to separate digits from operators in input?
  end

  #switch the expression from normal notation to Reverse Polish Notation,
  # save to @post_list (which is a stack)
  def switch_expression (in_list)
    operator_stack = Array.new
    post_list = Array.new
    in_list.each do |elem|
      if numeric?(elem)  #if the element is a number, push to post_list stack
        post_list.push(elem)
      elsif operator?(elem) then
        if elem == '('  ##if the elem is '(', push to operator stack
          operator_stack.push(elem)
        elsif elem == ')'
          #if it is ')', pop the operator stack until '(' is popped out,
          #and push them to post_list except for '('
          while operator_stack.last != '(' do
            post_list.push(operator_stack.pop)
          end
          operator_stack.pop
        else #if it is one of '+-*/'
          stacktop = operator_stack.last
          while (not operator_stack.empty?) and stacktop != '(' and ((stacktop == '*' or stacktop == '/') or ((stacktop == '+' or stacktop == '-') and (elem == '+' or elem == '-'))) do
            #If the element is * or /, then pop out operator stack until it reaches '('
            #If the element is + or -, then pop out operator stack until it reaches '(', '*', or '/'
            #For each one popped out from operator stack, push it to post_list stack
            post_list.push(operator_stack.pop)
            stacktop = operator_stack.last
          end
          operator_stack.push(elem)
          #then push in the element (+-*/)
        end
      end
    end
    until operator_stack.empty? do
      #finally, pop out the whole operator stack and push to post_list
      post_list.push(operator_stack.pop)
    end
    post_list
  end

  def operation(operand1, operand2, operator)
    return (operand1 + operand2) if operator == '+'
    return (operand1 - operand2) if operator == '-'
    return (operand1 * operand2) if operator == '*'
    if operator == '/'
      begin
        return (operand1 / operand2)
      rescue # if operand2 == 0
        return Float::INFINITY * operand1 #could be negative infinity
      end
    end
  end

  def calculate (post_list) #calculate final result of the expression from Reverse Polish Notation
    calculate_stack = Array.new
    post_list.each do |elem|
      if numeric?(elem)
        calculate_stack.push(elem)
      else
        operand2 = calculate_stack.pop
        operand1 = calculate_stack.pop
        calculate_stack.push(operation(operand1, operand2, elem))
      end
    end
    answer = calculate_stack.pop
    return answer
  end

  #print_result method
  def print_result
    @post_list.each do |elem|
      if numeric? elem and elem % 1.0 == 0.0
        print "#{Integer(elem)} "
        #print "#{elem} "
      else
        print "#{elem} "
      end
    end
    puts
    if numeric?(@answer) and @answer % 1 == 0
      puts "The result is #{Integer(@answer)}"
    else
      puts "The result is #{@answer}"
    end
  end

end

Calculator.new("1.9 + 1.1").print_result

