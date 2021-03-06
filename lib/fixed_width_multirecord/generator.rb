class FixedWidthMultirecord
  class Generator
    attr_accessor :record_separator
    def initialize(definition,separator = "\n")
      @definition = definition
      @record_separator = separator
    end

    def generate(data)
      @builder = []
      @definition.sections.each do |section|
        content = nil
        if data.is_a?(Hash)
          content = data[section.name]
        else
          content = data.send(section.name)
        end

        arrayed_content = content.is_a?(Array) ? content : [content]
        raise FixedWidthMultirecord::RequiredSectionEmptyError.new("Required section '#{section.name}' was empty.") if (content.nil? || content.empty?) && !section.optional
        arrayed_content.each {|row| @builder << section.format(row) }
      end
      @builder << "" # so we get a final record separator
      @builder.flatten.join(record_separator)
    end

  end
end
