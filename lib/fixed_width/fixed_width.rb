class FixedWidth
  class ParserError < RuntimeError; end
  class DuplicateColumnNameError < StandardError; end
  class DuplicateGroupNameError < StandardError; end
  class RequiredSectionNotFoundError < StandardError; end
  class RequiredSectionEmptyError < StandardError; end
  class FormattedStringExceedsLengthError < StandardError; end
  class ColumnMismatchError < StandardError; end

  def self.define(name, options = {}, &block)
    definition = Definition.new(options)
    yield(definition)
    definitions[name] = definition
    definition
  end

  def self.generate(definition_name, data)
    definition = definition(definition_name)
    raise ArgumentError.new("Definition name '#{name}' was not found.") unless definition
    generator = Generator.new(definition)
    generator.generate(data)
  end

  def self.write(file, definition_name, data)
    file.write(generate(definition_name, data))
  end

  def self.parse(file, definition_name)
    definition = definition(definition_name)
    raise ArgumentError.new("Definition name '#{definition_name}' was not found.") unless definition
    parser = Parser.new(definition, file)
    parser.parse
  end

  private

  def self.definitions
    @@definitions ||= {}
  end

  def self.definition(name)
    definitions[name]
  end
end