# ws.rb

# Only run the main logic if the script is invoked directly
if __FILE__ == $0
  input_file = ARGV[0]
  unless input_file
    puts "Usage: ruby ws.rb input-xxx.txt"
    exit 1
  end

  # Extract input file name and create output file name
  digits = input_file.match(/input-(\d{3})\.txt/)[1]
  output_file = File.join('output', "output-#{digits}.txt") # Write to output/ directory

  # Initialize stack
  stack = []

  begin
    # Read input file
    File.open(input_file, 'r') do |file|
      file.each_line do |line|
        elements = line.split
        elements.each do |element|
          case element
          when /\d+/ # Integer
            stack.push(element.to_i)
          when '+', '-', '*', '/', '**', '%'
            b = stack.pop
            a = stack.pop
            stack.push(a.send(element, b))
          when 'DROP'
            stack.pop
          when 'DUP'
            stack.push(stack.last)
          when 'SWAP'
            a, b = stack.pop(2)
            stack.push(b, a)
          when 'ROT'
            a, b, c = stack.pop(3)
            stack.push(b, c, a)
          when 'ROLL'
            n = stack.pop
            elements_to_rotate = stack.pop(n)
            stack.push(*elements_to_rotate.rotate)
          when 'ROLLD'
            n = stack.pop
            if n > 0 && n <= stack.length
              elements_to_rotate = stack.pop(n)
              stack.push(elements_to_rotate[-1], *elements_to_rotate[0..-2])
            end
          when 'IFELSE'
            condition = stack.pop
            false_case = stack.pop
            true_case = stack.pop
            if condition != 0 && condition != false
              stack.push(true_case)
            else
              stack.push(false_case)
            end
          when '==', '!=', '>', '<', '>=', '<=', '<=>'
            b = stack.pop
            a = stack.pop
            stack.push(a.send(element, b))
          when '&', '|', '^'  # Logical operators (and, or, xor)
            b = stack.pop
            a = stack.pop
            stack.push(a.send(element, b))
          when 'true'
            stack.push(true)
          when 'false'
            stack.push(false)
          when '"', '"'  # String operands
            string = stack.pop
            stack.push(string)
          when '<<', '>>'  # Bitshift operators
            b = stack.pop
            a = stack.pop
            stack.push(a.send(element, b))
          else
            # Handle unknown elements (optional)
          end
        end
      end
    end

    # Write stack to output file
    File.open(output_file, 'w') do |file|
      stack.each { |element| file.puts(element) }
    end
  rescue => e
    # Handle errors gracefully
    puts "Error: #{e.message}"
  end
end
