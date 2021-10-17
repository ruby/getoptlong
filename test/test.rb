require 'getoptlong'
opts = GetoptLong.new(
  ['--xxx', '-x', '--aaa', '-a', GetoptLong::REQUIRED_ARGUMENT],
  ['--yyy', '-y', '--bbb', '-b', GetoptLong::OPTIONAL_ARGUMENT],
  ['--zzz', '-z', '--ccc', '-c', GetoptLong::NO_ARGUMENT]
)
opts.each do |opt, arg|
  puts "#{opt} => #{arg}"
end



