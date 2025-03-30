module Arithmetic
  def self.handle_operation(stack, operator)
    # Handle binary operations
    if %w[+ - * / ** % & | ^ << >>].include?(operator)
      b = stack.pop
      a = stack.pop
      stack.push(a.send(operator, b))
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
    a = stack.pop
    b = stack.pop
    c = stack.pop
    stack.push(b, a, c)
  end

  def self.roll(stack)
    n = stack.pop
    elements_to_rotate = stack.pop(n)
    stack.push(*elements_to_rotate.rotate)
  end

  def self.rolld(stack)
    n = stack.pop
    if n > 0 && n <= stack.length
      elements_to_rotate = stack.pop(n)
      stack.push(elements_to_rotate[-1], *elements_to_rotate[0..-2])
    end
  end
end

module BooleanOperations
  def self.if_else(stack)
    condition = stack.pop
    false_case = stack.pop
    true_case = stack.pop
    if condition != 0 && condition != false
      stack.push(true_case)
    else
      stack.push(false_case)
    end
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
    puts "Usage: ruby ws.rb input-xxx.txt"
    exit 1
  end

  digits = input_file.match(/input-(\d{3})\.txt/)[1]
  output_file = File.join('output', "output-#{digits}.txt")

  stack = []

  begin
    # Read input file
    File.open(input_file, 'r') do |file|
      file.each_line do |line|
        elements = line.scan(/"[^"]*"|\S+/) # extract quoted strings and standalone tokens
        elements.each do |element|
          case element
          when /\d+/ # Integer
            stack.push(element.to_i)
          when '+', '-', '*', '/', '**', '%', '&', '|', '^', '<<', '>>', '!', '~'
            Arithmetic.handle_operation(stack, element)
          when 'DROP'
            StackManipulation.drop(stack)
          when 'DUP'
            StackManipulation.dup(stack)
          when 'SWAP'
            StackManipulation.swap(stack)
          when 'ROT'
            StackManipulation.rot(stack)
          when 'ROLL'
            StackManipulation.roll(stack)
          when 'ROLLD'
            StackManipulation.rolld(stack)
          when 'IFELSE'
            BooleanOperations.if_else(stack)
          when '==', '!=', '>', '<', '>=', '<=', '<=>'
            BooleanOperations.handle_comparison(stack, element)
          when 'true'
            stack.push(true)
          when 'false'
            stack.push(false)
          when /\A".*"\z/ # String
            stack.push(element[1..-2]) # remove quotes
          else
            puts "Unknown command: #{element}"
          end
        end
      end
    end

    # Write stack to output file
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
