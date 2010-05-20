require 'date'

class FixedWidth
  class ParserError < RuntimeError; end
  class Column
    DEFAULT_PADDING   = ' '
    DEFAULT_ALIGNMENT = :right
    DEFAULT_TRUNCATE  = false
    DEFAULT_FORMATTER = :to_s

    attr_reader :name, :length, :alignment, :type, :padding, :truncate, :unpacker

    def initialize(name, length, options = {})
      assert_valid_options(options)
      @name      = name
      @length    = length
      @alignment = options[:align]    || DEFAULT_ALIGNMENT
      @padding   = options[:padding]  || DEFAULT_PADDING
      @truncate  = options[:truncate] || DEFAULT_TRUNCATE

      @unpacker  = "A#{@length}"

      @parser    = options[:parser]
      @parser    ||= case @alignment
                 when :right then :lstrip
                 when :left  then :rstrip
                 end
      @parser    = @parser.to_proc if @parser.is_a?(Symbol)

      @formatter = options[:formatter]
      @formatter ||= DEFAULT_FORMATTER
      @formatter = @formatter.to_proc if @formatter.is_a?(Symbol)
    end

    def parse(value)
      @parser.call(value)
    rescue
      raise ParserError, "The value '#{value}' could not be parsed: #{$!}"
    end

    def format(value)
      pad(
        validate_size(
          @formatter.call(value)
        )
      )
    end

    private

    def pad(value)
      case @alignment
      when :left
        value.ljust(@length, @padding)
      when :right
        value.rjust(@length, @padding)
      end
    end

    def assert_valid_options(options)
      unless options[:align].nil? || [:left, :right].include?(options[:align])
        raise ArgumentError, "Option :align only accepts :right (default) or :left"
      end
    end

    def validate_size(result)
      return result if result.length <= @length
      raise FixedWidth::FormattedStringExceedsLengthError,
        "The formatted value '#{result}' in column '#{@name}' exceeds the allowed length of #{@length} chararacters." unless @truncate
      case @alignment
      when :right then result[-@length,@length]
      when :left  then result[0,@length]
      end
    end
  end
end