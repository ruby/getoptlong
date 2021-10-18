require 'getoptlong'
# This program supports testing.
# A test can execute the program with selected options and arguments,
# then capture and evaluate the output.
#
# The output is:
#
# - One line for each found option.
# - One line for each remaining element in ARGV.
# - The count of ARGV elements.
#   (This lets the test know now much of the output is ARGV,
#   and how much is options.)
opts = GetoptLong.new(
  ['--xxx', '-x', '--aaa', '-a', GetoptLong::REQUIRED_ARGUMENT],
  ['--yyy', '-y', '--bbb', '-b', GetoptLong::OPTIONAL_ARGUMENT],
  ['--zzz', '-z', '--ccc', '-c', GetoptLong::NO_ARGUMENT]
)
# Write each option and its argument.
opts.each do |opt, arg|
  puts "#{opt}: #{arg}"
end
# To keep the parsing simple in the test,
# write each ARGV element on a separate line.
puts ARGV
# The test will need to know how many of them there are.
puts ARGV.size
