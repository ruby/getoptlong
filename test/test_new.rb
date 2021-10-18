require 'test/unit'
require 'getoptlong'

class TestGetoptLong < Test::Unit::TestCase

  def setup
    # Nothing yet.
  end

  def teardown
    # Nothing yet.
  end

  # The target program is supposed to write:
  #
  # - One line for each option.
  # - One line for each element in ARGV.
  # - One line giving the count of ARGV elements.
  #
  # This is important because the test must know how to compare
  # options against options and ARGV elements against ARGV elements.
  #
  def verify_output(expected, output)
    # Don't mess with the caller's data.
    exp_entries = expected.dup
    act_entries = output.dup.split("\n")
    # The last act_entry is ARGV size as a string.
    # Get the ARGV elements into act_argv.
    argv_size = act_entries.pop.to_i
    act_argv = act_entries.pop(argv_size)
    # The last exp_entry is an array of expected argv strings.
    exp_argv = exp_entries.pop
    assert_equal(exp_argv, act_argv, 'ARGV')
    assert_equal(exp_entries.size, act_entries.size, 'Entries')
    i = 0
    exp_entries.zip(act_entries) do |exp, act|
      assert_equal(exp, act, "Entry #{i}")
      i += 1
    end
  end

  def test_new_with_no_array
    GetoptLong.new
  end

  def test_no_options
    output = `ruby test/options.rb foo bar`
    expected = [
      %w[foo bar]
    ]
    verify_output(expected, output)
  end

  def test_required_argument
    expected = [
      '--xxx: arg',
      %w[foo bar]
    ]
    options = %w[--xxx --xx --x -x --aaa --aa --a -a]
    options.each do |option|
      output = `ruby test/options.rb foo #{option} arg bar`
      verify_output(expected, output)
    end
  end

  # def test_required_argument_missing
  #   options = %w[--xxx --xx --x -x --aaa --aa --a -a]
  #   options.each do |option|
  #     expected = "option `--xxx' requires an argument (GetoptLong::MissingArgument)"
  #     _, err = capture_subprocess_io do
  #       `ruby test/options.rb --xxx`
  #     end
  #     assert_match(expected, err)
  #   end
  # end

  def test_optional_argument
    expected = [
      '--yyy: arg',
      %w[foo bar]
    ]
    options = %w[--yyy --y --y -y --bbb --bb --b -b]
    options.each do |option|
      output = `ruby test/options.rb foo bar #{option} arg`
      verify_output(expected, output)
    end
  end

  def test_optional_argument_missing
    expected = [
      '--yyy: ',
      %w[foo bar]
    ]
    options = %w[--yyy --y --y -y --bbb --bb --b -b]
    options.each do |option|
      output = `ruby test/options.rb foo bar #{option}`
      verify_output(expected, output)
    end
  end

  def test_no_argument
    expected = [
      '--zzz: ',
      %w[foo bar]
    ]
    options = %w[--zzz --zz --z -z --ccc --cc --c -c]
    options.each do |option|
      output = `ruby test/options.rb foo #{option} bar`
      verify_output(expected, output)
    end
  end

  def test_new_with_empty_array
    e = assert_raises(ArgumentError) do
      GetoptLong.new([])
    end
    assert_match(/no argument-flag/, e.message)
  end

  def test_new_with_bad_array
    e = assert_raises(ArgumentError) do
      GetoptLong.new('foo')
    end
    assert_match(/option list contains non-Array argument/, e.message)
  end

  def test_new_with_empty_subarray
    e = assert_raises(ArgumentError) do
      GetoptLong.new([[]])
    end
    assert_match(/no argument-flag/, e.message)
  end

  def test_new_with_bad_subarray
    e = assert_raises(ArgumentError) do
      GetoptLong.new([1])
    end
    assert_match(/no option name/, e.message)
  end

  def test_new_with_invalid_option
    invalid_options = %w[verbose -verbose -- +]
    invalid_options.each do |invalid_option|
      e = assert_raises(ArgumentError, invalid_option.to_s) do
        arguments = [
          [invalid_option, '-v', GetoptLong::NO_ARGUMENT]
        ]
        GetoptLong.new(*arguments)
      end
      assert_match(/invalid option/, e.message)
    end
  end

  def test_new_with_invalid_alias
    invalid_aliases = %w[v - -- +]
    invalid_aliases.each do |invalid_alias|
      e = assert_raises(ArgumentError, invalid_alias.to_s) do
        arguments = [
          ['--verbose', invalid_alias, GetoptLong::NO_ARGUMENT]
        ]
        GetoptLong.new(*arguments)
      end
      assert_match(/invalid option/, e.message)
    end
  end

  def test_new_with_invalid_flag
    invalid_flags = ['foo']
    invalid_flags.each do |invalid_flag|
      e = assert_raises(ArgumentError, invalid_flag.to_s) do
        arguments = [
          ['--verbose', '-v', invalid_flag]
        ]
        GetoptLong.new(*arguments)
      end
      assert_match(/no argument-flag/, e.message)
    end
  end

end
