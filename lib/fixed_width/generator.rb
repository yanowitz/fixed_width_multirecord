class FixedWidth
  class Generator

    def initialize(definition)
      @definition = definition
    end

    def generate(data)
      @builder = []
      @definition.sections.each do |section|
        content = data[section.name]
        arrayed_content = content.is_a?(Array) ? content : [content]
        raise FixedWidth::RequiredSectionEmptyError.new("Required section '#{section.name}' was empty.") if (content.nil? || content.empty?) && !section.optional
        arrayed_content.each {|row| @builder << section.format(row) }
      end
      @builder.join("\n")
    end

  end
end