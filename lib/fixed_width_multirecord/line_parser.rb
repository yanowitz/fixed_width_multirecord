class FixedWidthMultirecord
  class LineParser
    attr_reader :columns, :options
    def initialize(options={})
      @options      = options
      @columns      = []
      @name         = options[:name]
      @trap         = options[:trap]
    end

    ## Line definition
    def method_missing(name,length,*args)
      column(name,length,*args)
    end

    def column(name, length, options={})
      if column_names_by_group(options[:group]).include?(name)
        raise FixedWidthMultirecord::DuplicateColumnNameError.new("You have already defined a column named '#{name}' in the '#{options[:group].inspect}' group.")
      end
      if column_names_by_group(nil).include?(options[:group])
        raise FixedWidthMultirecord::DuplicateGroupNameError.new("You have already defined a column named '#{options[:group]}'; you cannot have a group and column of the same name.")
      end
      if group_names.include?(name)
        raise FixedWidthMultirecord::DuplicateGroupNameError.new("You have already defined a group named '#{name}'; you cannot have a group and column of the same name.")
      end

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

    def template(template_name)
      template = @options[:definition].templates[template_name]
      raise ArgumentError.new("Template '#{template_name}' not found as a known template.") unless template
      @columns += template.columns
      # Section options should trump template options
      @options = template.options.merge(@options)
    end

    ## Generating output
    def format(data)
      return nil unless data

      columns.map do |c|
        hash = c.group ? data[c.group] : data
        c.format(hash[c.name])
      end.join
    end

    ## Parsing input
    def match(raw_line)
      raw_line.nil? ? false : @trap.call(raw_line)
    end

    def parse(data,output={})
      return nil unless match(data.first)
      line = data.shift

      line_data = line.unpack(unpacker)
      row       = group_names.inject({}) {|h,g| h[g] = {}; h }

      @columns.each_with_index do |c, i|
        next if c.name == :spacer
        assignee         = c.group ? row[c.group] : row
        assignee[c.name] = c.parse(line_data[i])
      end

      row
    end

    private
    def column_names_by_group(group)
      @columns.select{|c| c.group == group }.map(&:name) - [:spacer]
    end

    def group_names
      @columns.map(&:group).compact.uniq
    end

    def unpacker
      @unpacker ||= @columns.map(&:unpacker).join
    end
  end
end

