class FixedWidth
  class Section
    attr_accessor :definition, :optional
    attr_reader :name, :columns, :options

    def initialize(name, options={})
      @name     = name
      @options  = options
      @columns  = []
      @trap     = options[:trap]
      @optional = options[:optional] || false
    end

    def column(name, length, options={})
      raise FixedWidth::DuplicateColumnNameError.new("You have already defined a column named '#{name}'.") if (@columns.map(&:name) - [:spacer]).include?(name)
      col = Column.new(name, length, @options.merge(options))
      @columns << col
      col
    end

    def spacer(length, spacer=nil)
      options           = {}
      options[:padding] = spacer if spacer
      column(:spacer, length, options)
    end

    def trap(&block)
      @trap = block
    end

    def template(name)
      template = @definition.templates[name]
      raise ArgumentError.new("Template '#{name}' not found as a known template.") unless template
      @columns += template.columns
      # Section options should trump template options
      @options = template.options.merge(@options)
    end

    def format(data)
      @columns.map{|column| column.format(data[column.name]) }.join
    end

    def parse(line)
      line_data = line.unpack(unpacker)
      row = {}
      @columns.each_with_index do |c, i|
        row[c.name] = c.parse(line_data[i]) unless c.name == :spacer
      end
      row
    end

    def match(raw_line)
      raw_line.nil? ? false : @trap.call(raw_line)
    end

    def method_missing(method, *args)
      column(method, *args)
    end

    private

    def unpacker
      @unpacker ||= @columns.map(&:unpacker).join
    end
  end
end