require 'test/unit'
require 'getoptlong'

class TestGetoptLong < Test::Unit::TestCase

  def getoptlong_new(argv: [], env: nil, options: nil)
    options ||= [
      ['--xxx', '-x', '--aaa', '-a', GetoptLong::REQUIRED_ARGUMENT],
      ['--yyy', '-y', '--bbb', '-b', GetoptLong::OPTIONAL_ARGUMENT],
      ['--zzz', '-z', '--ccc', '-c', GetoptLong::NO_ARGUMENT]
    ]
    env ||= ENV

    GetoptLong.new(*options, argv:, env:)
              .tap { |opts| opts.quiet = true }
  end

  def verify(test_argv, expected_remaining_argv, expected_options, env = nil)
    # Define options.
    opts = getoptlong_new(argv: test_argv, env:)
    yield opts if block_given?

    # Gather options.
    actual_options = []
    opts.each do |opt, arg|
      actual_options << "#{opt}: #{arg}"
    end

    # Assert.
    assert_equal(expected_remaining_argv, test_argv, 'ARGV')
    assert_equal(expected_options, actual_options, 'Options')
  end

  def test_no_options
    expected_options = []
    expected_argv = %w[foo bar]
    argv = %w[foo bar]
    verify(argv, expected_argv, expected_options)
  end

  def test_required_argument
    expected_options = [
      '--xxx: arg'
    ]
    expected_argv = %w[foo bar]
    options = %w[--xxx --xx --x -x --aaa --aa --a -a]
    options.each do |option|
      argv = ['foo', option, 'arg', 'bar']
      verify(argv, expected_argv, expected_options)
    end
  end

  def test_required_argument_missing
    options = %w[--xxx --xx --x -x --aaa --aa --a -a]
    options.each do |option|
      argv = [option]
      e = assert_raise(GetoptLong::MissingArgument) do
        verify(argv, [], [])
      end
      assert_match('requires an argument', e.message)
    end
  end

  def test_optional_argument
    expected_options = [
      '--yyy: arg'
    ]
    expected_argv = %w[foo bar]
    options = %w[--yyy --y --y -y --bbb --bb --b -b]
    options.each do |option|
      argv = ['foo', 'bar', option, 'arg']
      verify(argv, expected_argv, expected_options)
    end
  end

  def test_optional_argument_missing
    expected_options = [
      '--yyy: '
    ]
    expected_argv = %w[foo bar]
    options = %w[--yyy --y --y -y --bbb --bb --b -b]
    options.each do |option|
      argv = ['foo', 'bar', option]
      verify(argv, expected_argv, expected_options)
    end
  end

  def test_no_argument
    expected_options = [
      '--zzz: '
    ]
    expected_argv = %w[foo bar]
    options = %w[--zzz --zz --z -z --ccc --cc --c -c]
    options.each do |option|
      argv = ['foo', option, 'bar']
      verify(argv, expected_argv, expected_options)
    end
  end

  def test_new_with_empty_array
    e = assert_raise(ArgumentError) do
      GetoptLong.new([])
    end
    assert_match(/no argument-flag/, e.message)
  end

  def test_new_with_bad_array
    e = assert_raise(ArgumentError) do
      GetoptLong.new('foo')
    end
    assert_match(/option list contains non-Array argument/, e.message)
  end

  def test_new_with_empty_subarray
    e = assert_raise(ArgumentError) do
      GetoptLong.new([[]])
    end
    assert_match(/no argument-flag/, e.message)
  end

  def test_new_with_bad_subarray
    e = assert_raise(ArgumentError) do
      GetoptLong.new([1])
    end
    assert_match(/no option name/, e.message)
  end

  def test_new_with_invalid_option
    invalid_options = %w[verbose -verbose -- +]
    invalid_options.each do |invalid_option|
      e = assert_raise(ArgumentError, invalid_option.to_s) do
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
      e = assert_raise(ArgumentError, invalid_alias.to_s) do
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
      e = assert_raise(ArgumentError, invalid_flag.to_s) do
        arguments = [
          ['--verbose', '-v', invalid_flag]
        ]
        GetoptLong.new(*arguments)
      end
      assert_match(/no argument-flag/, e.message)
    end
  end

  def test_raise_ambiguous_option
    e = assert_raise(GetoptLong::AmbiguousOption) do
      options = [
        ['--xxx', GetoptLong::REQUIRED_ARGUMENT],
        ['--xxy', GetoptLong::NO_ARGUMENT]
      ]
      getoptlong_new(argv: ['--xx'], options:).each { nil }
    end
    assert_match(/ambiguous/, e.message)
  end

  def test_option_prefix
    assert_nothing_raised do
      options = [
        ['--xxx',   GetoptLong::NO_ARGUMENT],
        ['--xxx-y', GetoptLong::NO_ARGUMENT],
        ['--xx',    GetoptLong::NO_ARGUMENT]
      ]
      getoptlong_new(argv: ['--xx', '--xxx'], options:).each { nil }
    end
  end

  def test_raise_needless_argument
    e = assert_raise(GetoptLong::NeedlessArgument) do
      options = [['--x', GetoptLong::NO_ARGUMENT]]
      getoptlong_new(argv: ['--x=z'], options:).each { nil }
    end
    assert_match(/doesn't allow an argument/, e.message)
  end

  def test_raise_too_many_flags
    e = assert_raise(ArgumentError) do
      options = [
        ['-y', GetoptLong::REQUIRED_ARGUMENT, GetoptLong::NO_ARGUMENT]
      ]
      getoptlong_new(options:)
    end
    assert_match(/too many/, e.message)
  end

  def test_raise_option_redefined
    e = assert_raise(ArgumentError) do
      options = [
        ['--xxx', '-x', GetoptLong::REQUIRED_ARGUMENT],
        ['--exclude', '-x', GetoptLong::NO_ARGUMENT]
      ]
      getoptlong_new(options:)
    end
    assert_match(/redefined/, e.message)
  end

  def test_set_ordering_raise
    e = assert_raise(ArgumentError) do
      getoptlong_new.ordering = 42
    end
    assert_match(/invalid ordering/, e.message)
  end

  def test_raise_unrecognized_option
    e = assert_raise(GetoptLong::InvalidOption) do
      getoptlong_new(argv: ['--asdf']).each { nil }
    end
    assert_match(/unrecognized option/, e.message)
  end

  def test_ordering
    GetoptLong::ORDERINGS.each do |order|
      argv = ['foo', '--xxx', 'arg', 'bar']

      expected_options, expected_argv =
        case order
        when GetoptLong::REQUIRE_ORDER
          [[], %w[foo --xxx arg bar]]
        when GetoptLong::PERMUTE
          [['--xxx: arg'], %w[foo bar]]
        when GetoptLong::RETURN_IN_ORDER
          [[': foo', '--xxx: arg', ': bar'], []]
        end

      verify(argv, expected_argv, expected_options) do |opts|
        opts.ordering = order
      end
    end
  end

  def test_env_posixly_correct
    [{}, { 'POSIXLY_CORRECT' => '1' }].each do |order|
      argv = ['foo', '--xxx', 'arg', 'bar']

      expected_options, expected_argv =
        case order
        when {}
          [['--xxx: arg'], %w[foo bar]]
        else
          [[], %w[foo --xxx arg bar]]
        end

      verify(argv, expected_argv, expected_options, order)
    end
  end

  def test_raise_invalid_option_with_single_hyphen
    options = [
      ['-x', GetoptLong::NO_ARGUMENT],
      ['--x', GetoptLong::NO_ARGUMENT]
    ]
    argvs = [%w[-x-x foo], %w[-x- foo]]

    argvs.each do |argv|
      e = assert_raise(GetoptLong::InvalidOption) do
        getoptlong_new(argv:, options:).each { nil }
      end
      assert_match(/invalid option/, e.message)
    end
  end

end
