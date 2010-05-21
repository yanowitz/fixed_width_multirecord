class FixedWidth
  class Generator

    def initialize(definition)
      @definition = definition
    end

    def generate(data)
      @builder = []
      @definition.sections.each do |section|
        content = data[section.name]
        raise FixedWidth::RequiredSectionEmptyError.new("Required section '#{section.name}' was empty.") if (content.nil? || content.empty?) && !section.optional
        Array(content).each {|row| @builder << section.format(row) }
      end
      @builder.join("\n")
    end

  end
end