class FixedWidthMultirecord
  class Definition
    attr_reader :sections, :templates, :options

    def initialize(options={})
      @sections  = []
      @templates = {}
      @options   = { :align => :right }.merge(options)
      @options[:definition] = self
    end

    def section(name, options={}, &block)
      raise DuplicateSectionNameError.new("Duplicate section name: '#{name}'") if @sections.detect{|s| s.name == name }

      section = FixedWidthMultirecord::Section.new(name, @options.merge(options), &block)
      @sections << section
    end

    def template(name, options={}, &block)
      section = FixedWidthMultirecord::Section.new(name, @options.merge(options), &block)
      @templates[name] = section
    end

    def method_missing(method, *args, &block)
      section(method, *args, &block)
    end
  end
end
