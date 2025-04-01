require 'matrix'

class Calculator
  attr_accessor :stack, :tokens
  def initialize(tokens)
    @tokens = tokens
    @stack = []
  end

  def evaluate
    while (element = @tokens.shift)
      case element
      when Integer
        @stack.push(element)
      when 'true'
        @stack.push(true)
      when 'false'
        @stack.push(false)
      when /\A".*"\z/
        @stack.push(element[1..-2])
      when '+', '-', '*', '/', '**', '%', '&', '|', '^', '<<', '>>', '!', '~'
        Arithmetic.handle_operation(@stack, element)
      when 'DROP'
        StackManipulation.drop(@stack)
      when 'DUP'
        StackManipulation.dup(@stack)
      when 'SWAP'
        StackManipulation.swap(@stack)
      when 'ROT'
        StackManipulation.rot(@stack)
      when 'ROLL'
        StackManipulation.roll(@stack)
      when 'ROLLD'
        StackManipulation.rolld(@stack)
      when 'IFELSE'
        BooleanOperations.if_else(@stack)
      when '==', '!=', '>', '<', '>=', '<=', '<=>'
        BooleanOperations.handle_comparison(@stack, element)
      else
        puts "Unknown command: #{element}"
      end
    end
    @stack
  end


  private

  def extract_lambda_tokens
    # Logic to extract lambda tokens from the stack
    []
  end
end

module Arithmetic
  def self.handle_operation(stack, operator)
    # Handle binary operations
    if %w[+ - * / ** % & | ^ << >>].include?(operator)
      b = stack.pop
      a = stack.pop

      a = a.to_i if a.is_a?(Integer)
      b = b.to_i if b.is_a?(Integer)
      result = a.send(operator, b)
      stack.push(result)
    elsif operator == '!'
      stack.push(!stack.pop)
    elsif operator == '~' # One's complement
      stack.push(~stack.pop)
    end
  end
end

module StackManipulation
  def self.drop(stack)
    stack.pop
  end

  def self.dup(stack)
    stack.push(stack.last)
  end

  def self.swap(stack)
    a, b = stack.pop(2)
    stack.push(b, a)
  end

  def self.rot(stack)
    a, b, c = stack.pop(3)
    stack.push(b, c, a)
  end

  def self.roll(stack)
    n = stack.pop
    elements_to_rotate = stack.pop(n)
    stack.push(*elements_to_rotate.rotate)
  end

  def self.rolld(stack)
    n = stack.pop
    elements_to_rotate = stack.pop(n)
    stack.push(elements_to_rotate[-1], *elements_to_rotate[0..-2])
  end
end

module BooleanOperations
  def self.if_else(stack)
    condition = stack.pop
    false_case = stack.pop
    true_case = stack.pop
    stack.push(condition ? true_case : false_case)
  end

  def self.handle_comparison(stack, operator)
    b = stack.pop
    a = stack.pop
    result = case operator
             when '==' then a == b
             when '!=' then a != b
             when '>' then a > b
             when '<' then a < b
             when '>=' then a >= b
             when '<=' then a <= b
             when '<=>' then a <=> b
             end
    stack.push(result)
  end
end


if __FILE__ == $0
  input_file = ARGV[0]
  unless input_file
    puts "Usage: ruby calculator.rb input-xxx.txt"
    exit 1
  end

  digits = input_file.match(/input-(\d{3})\.txt/)[1]
  output_file = File.join('output', "output-#{digits}.txt")

  tokens = []
  begin
    # Load the tokens from the input file
    File.open(input_file, 'r') do |file|
      file.each_line do |line|
        line.scan(/"[^"]*"|\S+/).each do |token|
          # Check if the token is an integer using a regular expression and convert if true
          parsed_token = token.match?(/\A-?\d+\z/) ? token.to_i : token
          tokens << parsed_token
        end
      end
    end

    calculator = Calculator.new(tokens)
    stack = calculator.evaluate

    File.open(output_file, 'w') do |file|
      stack.each do |element|
        formatted_element = element.is_a?(String) ? "\"#{element}\"" : element
        file.puts(formatted_element)
      end
    end
  rescue => e
    puts "Error: #{e.message}"
  end
end
