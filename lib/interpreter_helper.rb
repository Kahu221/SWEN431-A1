class InterpreterHelper
  def self.run_interpreter(input_file)
    # Execute ws.rb with the input file
    system("ruby ws.rb #{input_file}")

    # Return the path to the output file
    digits = input_file.match(/input-(\d{3})\.txt/)[1]
    File.join('output', "output-#{digits}.txt") # Output files are in output/ directory
  end
end