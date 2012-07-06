class FixedWidth
  class Generator
    attr_accessor :record_separator
    def initialize(definition,separator = "\n")
      @definition = definition
      @record_separator = separator
    end

    def generate(data)
      @builder = []
      @definition.sections.each do |section|
        content = data[section.name]
        arrayed_content = content.is_a?(Array) ? content : [content]
        raise FixedWidth::RequiredSectionEmptyError.new("Required section '#{section.name}' was empty.") if (content.nil? || content.empty?) && !section.optional
        arrayed_content.each {|row| @builder << section.format(row) }
      end
      @builder << "" # so we get a final record separator
      @builder.flatten.join(record_separator)
    end

  end
end
