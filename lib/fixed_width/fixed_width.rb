#
# =DESCRIPTION:
# 
# A simple, clean DSL for describing, writing, and parsing fixed-width text files.
# 
# =FEATURES:
# 
# * Easy DSL syntax
# * Can parse and format fixed width files
# * Templated sections for reuse
#
# For examples, see examples/*.rb or the README.
#
class FixedWidth
  class ParserError < RuntimeError; end
  class DuplicateColumnNameError < StandardError; end
  class DuplicateGroupNameError < StandardError; end
  class DuplicateSectionNameError < StandardError; end
  class RequiredSectionNotFoundError < StandardError; end
  class RequiredSectionEmptyError < StandardError; end
  class FormattedStringExceedsLengthError < StandardError; end
  class ColumnMismatchError < StandardError; end

  #
  # [name]   a symbol to reference this file definition later
  # [option] a hash of default options for all sub-elements
  # and a block that defines the sections of the file.
  #
  # returns: +Definition+ instance for this file description.
  #
  def self.define(name, options={}) # yields definition
    definition = Definition.new(options)
    yield(definition)
    definitions[name] = definition
    definition
  end

  #
  # [data]            nested hash describing the contents of the sections
  # [definition_name] symbol +name+ used in +define+
  #
  # returns: string of the transformed +data+ (into fixed-width records).
  #
  def self.generate(definition_name, data)
    definition = definition(definition_name)
    raise ArgumentError.new("Definition name '#{name}' was not found.") unless definition
    generator = Generator.new(definition)
    generator.generate(data)
  end

  #
  # [file]            IO object to write the +generate+d data
  # [definition_name] symbol +name+ used in +define+
  # [data]            nested hash describing the contents of the sections
  #
  # writes transformed data to +file+ object as fixed-width records.
  #
  def self.write(file, definition_name, data)
    file.write(generate(definition_name, data))
  end

  #
  # [file]            IO object from which to read the fixed-width text records
  # [definition_name] symbol +name+ used in +define+
  #
  # returns: parsed text records in a nested hash.
  #
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