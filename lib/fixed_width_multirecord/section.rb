class FixedWidthMultirecord
  class Section
    attr_accessor :definition, :optional, :singular
    attr_reader :options, :first_line_parser, :additional_lines

    def short_name
      @name
    end

    def name
      @parent ? (@parent.name.to_s + "::#{@name}") : @name
    end

    def initialize(section_name, options={}, &block)
      @name        = section_name
      @options     = options
      @optional    = options[:optional] || false
      @singular    = options[:singular] || false
      @parent      = options[:parent]
      @definition  = options[:definition]

      @first_line_parser = FixedWidthMultirecord::LineParser.new(options.merge(:name => @name))

      @additional_lines = []

      block.call(self)
    end

    ## Used for Section Definition
    def method_missing(method, *args, &block)
      @first_line_parser.send(method, *args, &block)
    end

    def line(line_name, options = {}, &block)
      options[:parent] = self
      @additional_lines << self.class.new(line_name, @options.merge(options), &block)
    end

    ## Used for Section Output
    def format(data)
      return [] unless data
 
      lines = [@first_line_parser.format(data)]
      @additional_lines.each do |line_parser|
        data_to_parse = if data.is_a?(Hash)
          data[line_parser.short_name]
        else
          data.send(line_parser.short_name)
        end

        next unless data_to_parse
        data_to_parse = [data_to_parse] unless data_to_parse.is_a?(Array)

        data_to_parse.each do |row|
          lines << line_parser.format(row)
        end
      end
      lines.compact
    end

    ## Used for Section Input (parsing)
    def parse( params )
      input = params[:input]
      output = params[:output]

      rows = []

      while row = process_record(input)
        rows << row
      end

      if !rows.empty?
        if singular
          output[@name] = rows.last
        else
          output[@name] = rows
        end
      end

      if !self.optional && (!output[@name] || output[@name].empty?)
        raise FixedWidthMultirecord::RequiredSectionNotFoundError.new("Required section '#{name}' was not found.")
      end
    end

    private
    def process_record(input)
      record = @first_line_parser.parse(input)

      return nil unless record

      @additional_lines.each do |section|
        while section.parse(:input => input, :output => record)
        end
      end

      record
    end
  end
end
