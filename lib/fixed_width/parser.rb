class FixedWidth
  class Parser
    def initialize(definition, file)
      @definition = definition
      @file       = file
    end

    def parse
      @parsed = {}
      @content = read_file
      unless @content.empty?
        @definition.sections.each do |section|
          section.parse(:input => @content, :output => @parsed)
        end
      end
      @parsed
    end

    private
    def read_file
      @file.readlines.map(&:chomp)
    end
  end
end
