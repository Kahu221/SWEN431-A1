require 'matrix'

class ExpressionProcessor
  attr_accessor :stack
  class MatrixVector < Vector
    def self.from_string(element)
      vector_pattern = /\[-?\d+(?:,\s*-?\d+)+\]/
      array_elements = element.scan(vector_pattern).map do |a|
        a.gsub(/[\[\]]/, '').split(/\s*,\s*/).map(&:to_i)
      end
      array_elements.length > 1 ? Matrix.rows(array_elements) : elements(array_elements.first)
    end

    def *(other)
      if other.is_a?(Vector)
        self.inner_product(other)
      else
        super
      end
    end

    def x(other)
      self.cross_product(other)
    end
  end

  VECTOR_MATRIX_PATTERN = /(\[.+\])/
  EVAL_PATTERN = /'.*/
  LAMBDA_PATTERN = /({\s*\d+\s*\|\s*.*\s*})/

  def initialize
    @stack = []
  end

  def rotate_last(elements, direction)
    rotated = @stack.last(elements).rotate(direction)
    @stack.pop(elements)
    @stack.concat(rotated)
  end

  def process_lambda(lambda)
    matches = lambda.match(/{\s*(\d+)\s*\|\s*(.*?)\s*}/)
    n = matches.captures[0].to_i
    x = @stack.pop(n)
    matches.captures[1].split.each do |command|
      if command.match(/^x\d+$/)
        index = command[1..].to_i
        process_element(x[index])
      elsif command == "SELF"
        @stack.push(lambda)
      else
        command = Integer(command) rescue command
        process_element(command)
      end
    end
  end

  def process_element(element)
    integer_pattern = /\A-?\d+\z/
    float_pattern = /\A-?\d+\.\d+\z/

    case element
    when VECTOR_MATRIX_PATTERN then @stack.push(MatrixVector.from_string(element))
    when LAMBDA_PATTERN then process_lambda(element)
    when integer_pattern then @stack.push(element.to_i)
    when float_pattern then @stack.push(element.to_f)
    when EVAL_PATTERN
      command = Integer(element[1..]) rescue element
      @stack.push(command)
    when "true", "false" then @stack.push(element == "true")
    when '+', '-', '*', '/', '**', '%', '==', '!=', '>', '<', '>=', '<=', '<=>', '&', '|', '^', '<<', '>>', 'x'
      b = @stack.pop
      a = @stack.pop
      @stack.push(a.send(element, b))
    when '!', '~'
      a = @stack.pop
      @stack.push(a.send(element))
    when 'SWAP'
      a = @stack.pop
      b = @stack.pop
      @stack.push(a)
      @stack.push(b)
    when 'DROP' then @stack.pop
    when 'DUP'then @stack.push(@stack.last)
    when 'ROT' then rotate_last(3, 1)
    when 'ROLL' then
      last = @stack.pop
      rotate_last(last, 1)
    when 'ROLLD'
      last = @stack.pop
      rotate_last(last, -1)
    when 'IFELSE'
      boolean = @stack.pop
      a = @stack.pop
      b = @stack.pop
      if boolean
        @stack.push(b)
      else
        @stack.push(a)
      end
    when 'TRANSP'
      a = @stack.pop
      @stack.push(a.transpose)
    when 'EVAL'
      command = @stack.pop
      command.match?(LAMBDA_PATTERN) ? process_element(command) : process_element(command[1..])
    else
      @stack.push(element)
    end
  end

  def process_elements(elements)
    elements.each do |element|
      process_element(element)
    end
  end
end

def read_file(input_file)
  elements = []
  File.open(input_file, 'r') do |file|
    file.each_line do |line|
      string_pattern = /"([^"]*)"/
      operator_pattern = /(\S+)/

      pattern = Regexp.union(string_pattern, ExpressionProcessor::VECTOR_MATRIX_PATTERN, ExpressionProcessor::LAMBDA_PATTERN, operator_pattern)
      elements.concat(line.scan(pattern).flatten.compact)
    end
  end
  elements
end

def write_file(output_file, result)
  File.open(output_file, 'w') do |file|
    result.each do |element|
      if element.is_a?(String)
        if element.match?(ExpressionProcessor::EVAL_PATTERN)
          file.puts element[1..]
        else
          file.puts("\"#{element}\"")
        end
      elsif element.is_a?(Vector) or element.is_a?(Matrix)
        file.puts("#{element.to_a}")
      else
        file.puts(element)
      end
    end
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

  elements = read_file(input_file)

  expression_processor = ExpressionProcessor.new
  expression_processor.process_elements(elements)

  write_file(output_file, expression_processor.stack)
end
