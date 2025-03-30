require_relative '../lib/interpreter_helper'


describe 'Stack Interpreter Debugging' do
  # Change this number to debug a specific test case
  test_number = '001'

  # Define paths to input and expected files
  input_file = File.join(File.dirname(__FILE__), "../input/input-#{test_number}.txt")
  expected_file = File.join(File.dirname(__FILE__), "../expected/expected-#{test_number}.txt")

  # Ensure the output directory exists
  output_dir = File.join(File.dirname(__FILE__), '../output')
  Dir.mkdir(output_dir) unless Dir.exist?(output_dir)

  it "correctly processes input-#{test_number}.txt" do
    expected_output = File.readlines(expected_file).map(&:chomp)

    output_file = InterpreterHelper.run_interpreter(input_file)
    actual_output = File.readlines(output_file).map(&:chomp)

    expect(actual_output).to eq(expected_output)

    # Clean up: Delete the output file after the test
    File.delete(output_file) if File.exist?(output_file)
  end
end

RSpec.describe 'Stack Interpreter' do
  input_dir = File.join(File.dirname(__FILE__), '../input')
  expected_dir = File.join(File.dirname(__FILE__), '../expected')

  output_dir = File.join(File.dirname(__FILE__), '../output')
  Dir.mkdir(output_dir) unless Dir.exist?(output_dir)

  input_files = Dir.glob(File.join(input_dir, 'input-*.txt'))

  input_files.each do |input_file|

    test_number = File.basename(input_file).match(/input-(\d{3})\.txt/)[1]
    # Define the corresponding expected file
    expected_file = File.join(expected_dir, "expected-#{test_number}.txt")

    # Dynamically create a test for this input/expected pair
    it "correctly processes input-#{test_number}.txt" do
      # Read the expected output
      expected_output = File.readlines(expected_file).map(&:chomp)

      # Run the interpreter using the helper class
      output_file = InterpreterHelper.run_interpreter(input_file)

      # Read the generated output file
      actual_output = File.readlines(output_file).map(&:chomp)

      # Compare actual output with expected output
      expect(actual_output).to eq(expected_output)

      # Clean up: Delete the output file after the test
      File.delete(output_file) if File.exist?(output_file)
    end
  end
end