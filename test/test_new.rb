require 'test/unit'
require 'getoptlong'

class TestGetoptLong < Test::Unit::TestCase

  def setup
    # Nothing yet.
  end

  def teardown
    # Nothing yet.
  end

  def test_new_with_no_array
    GetoptLong.new
  end

  def test_no_options
    output = `ruby test/test.rb`
    assert_equal(output, '')
  end

  def test_required_argument
    options = %w[--xxx --xx --x -x --aaa --aa --a -a]
    options.each do |option|
      output = `ruby test/test.rb #{option} arg`
      assert_equal("--xxx => arg\n", output)
    end
  end

  # def test_required_argument_missing
  #   options = %w[--xxx --xx --x -x --aaa --aa --a -a]
  #   options.each do |option|
  #     expected = "option `--xxx' requires an argument (GetoptLong::MissingArgument)"
  #     _, err = capture_subprocess_io do
  #       `ruby test/test.rb --xxx`
  #     end
  #     assert_match(expected, err)
  #   end
  # end

  def test_optional_argument
    options = %w[--yyy --y --y -y --bbb --bb --b -b]
    options.each do |option|
      output = `ruby test/test.rb #{option} arg`
      assert_equal("--yyy => arg\n", output)
    end
  end

  def test_optional_argument_missing
    options = %w[--yyy --y --y -y --bbb --bb --b -b]
    options.each do |option|
      output = `ruby test/test.rb #{option}`
      assert_equal("--yyy => \n", output)
    end
  end

  def test_no_argument
    options = %w[--zzz --zz --z -z --ccc --cc --c -c]
    options.each do |option|
      output = `ruby test/test.rb #{option}`
      assert_equal("--zzz => \n", output)
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
