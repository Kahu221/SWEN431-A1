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
  #TODO - Change the output file path to be in the correct dir
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
          when /\d+/ # Integer operand
            stack.push(element.to_i)
          when '+', '-', '*', '/', '**', '%' # Operators
            # Pop top two elements, perform operation, push result
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
    puts "Error: #{e.message}" # Remove this line in final submission
  end
end