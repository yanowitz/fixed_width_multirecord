require 'date'

class FixedWidth
  class ParserError < RuntimeError; end
  DEFAULT_PADDING = ' '

  class Column
    attr_reader :name, :length, :alignment, :type, :padding, :unpacker

    def initialize(name, length, options = {})
      assert_valid_options(options)
      @name          = name
      @length        = length

      @unpacker      = "A#{@length}"

      @alignment     = options[:align]    || :right
      @type          = options[:type]     || :string
      @padding       = options[:padding]  || DEFAULT_PADDING
      @truncate      = options[:truncate] || false

      # applies for parsing/writing :date
      @date_format  = options[:date_format]
      # applies for writing :float
      @float_format = options[:float_format]
    end

    def parse(value)
      case @type
      when :integer
        value.to_i
      when :float
        value.to_f
      when :date
        if @date_format
          Date.strptime(value, @date_format)
        else
          Date.strptime(value)
        end
      when :string
        case @alignment
        when :left  then value.lstrip
        when :right then value.rstrip
        end
      else
        raise "Undefined type #{@type} for column #{@name}!"
      end
    rescue
      raise ParserError, "The value '#{value}' could not be converted to type #{@type}: #{$!}"
    end

    def format(value)
      pad(to_s(value))
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

    def to_s(value)
      result = case @type
      when :date
        if value.respond_to?(:strftime)
          if @date_format
            value.strftime(@date_format)
          else
            value.strftime
          end
        else
          value.to_s
        end
      when :float
        if @float_format
          @float_format % value.to_f
        else
          value.to_f.to_s # minimal precision needed to render fully.
        end
      else
        value.to_s
      end
      validate_size(result)
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