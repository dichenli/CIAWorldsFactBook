#Dichen Li, HW2 part 1

#This program has a class Calculator, which asks you to input an arithmetic expression such as
#(1 + 1) * 3 / 2 + 10
#It transfers the expression to Reverse Polish notation, prints out the notation, and then
#calculates the result of the expression and prints it out.

#output is like:
##1.0 1.0 + 3.0 * 2.0 / 10.0 +
##The result is 13.0

#For now this program doesn't support negative numbers, non-decimal numbers, complex numbers or Klingon numbers

class Calculator
  @inElemList
  @postElemList
  @answer
  def operator?(char)
    operators = '()+-*/'
    operators.include?(char) rescue false
  end

  def digits?(char)
    digits = '0123456789.'
    digits.include?(char) rescue false
  end

  def numeric?(elem) #1 will return true, '1' will return false
    elem.to_f == elem
  end

  def initialize #It starts the calculator class
    @inElemList = Array.new
    @postElemList = Array.new
    readExpression
    switchExpression
    calculate
    output
  end

  def findLenOfNumber(string, index)
    #for a given input string of expression and a initial index, this method returns the length
    #of the string segment which represents the number starting from string[index]
    #for input ("1+1", 0), it returns 1, for ("1.0+1.0", 0), it returns 3
    i = index
    while i < string.length() and digits?(string[i]) do
      i += 1
    end
    return i - index
  end

  def readExpression
    #transfers an input string of expression to a list of numbers and operators
    inString = gets.chomp
    i = 0
    while i<inString.length() do
      if digits?(inString[i])
        len = findLenOfNumber(inString, i)
        @inElemList.push(Float(inString[i, len]))
        i = i + len
      elsif operator?(inString[i])
        @inElemList.push(inString[i])
        i = i + 1
      else
        i = i + 1
      end
    end
    ## How to separate digits from operators in input?
  end

  def switchExpression
    #switch the expression from normal notation to Reverse Polish Notation,
    # save to @postElemList (which is a stack)
    operatorStack = Array.new
    j = 0
    @inElemList.each do |elem|
      if numeric?(elem) then #if the element is a number, push to postElemList stack
        @postElemList.push(elem)
      elsif operator?(elem) then
        if elem == '(' then ##if the elem is '(', push to operator stack
          operatorStack.push(elem)
        elsif elem == ')' then
          #if it is ')', pop the operator stack until '(' is popped out,
          #and push them to postElemList except for '('
          while operatorStack.last() != '(' do
            @postElemList.push(operatorStack.pop())
          end
          operatorStack.pop()
        else #if it is one of '+-*/'
          stacktop = operatorStack.last()
          while (not operatorStack.empty?) and stacktop != '(' and ((stacktop == '*' or stacktop == '/') or ((stacktop == '+' or stacktop == '-') and (elem == '+' or elem == '-'))) do
            #If the element is * or /, then pop out operator stack until it reaches '('
            #If the element is + or -, then pop out operator stack until it reaches '(', '*', or '/'
            #For each one popped out from operator stack, push it to postElemList stack
            @postElemList.push(operatorStack.pop())
            stacktop = operatorStack.last()
          end
          operatorStack.push(elem)
          #then push in the element (+-*/)
        end
      end
    end
    while not operatorStack.empty? do
      #finally, pop out the whole operator stack and push to postElemList
      @postElemList.push(operatorStack.pop())
    end
  end

  def operation(operand1, operand2, operator)
    return (operand1 + operand2) if operator == '+'
    return (operand1 - operand2) if operator == '-'
    return (operand1 * operand2) if operator == '*'
    return (operand1 / operand2) if operator == '/'
  end

  def calculate #calculate final result of the expression from Reverse Polish Notation
    calculateStack = Array.new
    @postElemList.each do |elem|
      if numeric?(elem)
        calculateStack.push(elem)
      else
        operand2 = calculateStack.pop()
        operand1 = calculateStack.pop()
        calculateStack.push(operation(operand1, operand2, elem))
      end
    end
    @answer = calculateStack.pop()
  end

  def output #output method
    @postElemList.each do |elem|
      if numeric?(elem) and elem % 1 == 0
        print "#{Integer(elem)} "
      else
        print "#{elem} "
      end
    end
    puts
    if numeric?(@answer) and @answer % 1 == 0
      print "The result is #{Integer(@answer)}"
    else
      print "The result is #{@answer}"
    end
  end

end

def main
  calc = Calculator.new
end

main