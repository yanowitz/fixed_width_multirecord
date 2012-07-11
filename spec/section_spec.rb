require File.join(File.dirname(__FILE__), 'spec_helper')

describe FixedWidthMultirecord::Section do
  before(:each) do
    @section = FixedWidthMultirecord::Section.new(:body) {}
  end

  describe "section definitions" do
    it "initialises a line parser" do
      options = {:option1 => :value1}
      FixedWidthMultirecord::LineParser.should_receive(:new).with(options.merge(:name => :a_section_name))
      FixedWidthMultirecord::Section.new(:a_section_name, options) {}
    end

    it "yields the block it's passed" do
      yielded = false
      new_section = FixedWidthMultirecord::Section.new(:a_section_name) do |section|
        yielded = section
      end
      yielded.should == new_section
    end

    it "delegates column definitions to the line parser" do
      line_parser = @section.first_line_parser
      line_parser.should_receive(:some_column_name).with(10, :some_option => :that_gets_passed_through)
      @section.some_column_name( 10, :some_option => :that_gets_passed_through )
    end

    describe "#columns" do
      it "proxies columns to the first_line_parser" do
        @section.first_line_parser.should_receive(:columns)
        @section.columns
      end
    end

    describe "#line" do
      it "creates additional sections (with a parent relationship)" do
        mock_section = mock(FixedWidthMultirecord::Section)
        FixedWidthMultirecord::Section.should_receive(:new).with(:second_record, {:parent => @section}).and_yield(mock_section)
        second_record = nil
        @section.line( :second_record ) do |section|
          second_record = section
        end
        second_record.should == mock_section
        @section.additional_lines.should == [mock_section]
      end
    end
  end

  describe "#name" do
    it "builds a name based on the parent relationships" do
      @child           = FixedWidthMultirecord::Section.new(:child, :parent => @section) {} 
      @grandchild      = FixedWidthMultirecord::Section.new(:grandchild, :parent => @child) {} 
      @section.name    == "body"
      @child.name      == "body::child"
      @grandchild.name == "body::child::grandchild"
    end
  end

  describe "#parse" do
    before(:each) do
      @column_content = { :id => 5, :first => 10, :last => 10, :state => 2 }
      @section = FixedWidthMultirecord::Section.new(:body, :optional => true) do |section|
        @column_content.each { |k,v| section.column(k, v) }
      end

      @input = ["some fake data"]
      @parsed_input = { :id => '45', :first => 'Ryan', :last => 'Wood', :state => 'SC' } 
      @output = {}

      @section.stub(:process_record).and_return(nil)
    end

    it "keeps the last row processed if the record is singular" do
      @section.should_receive(:process_record).and_return(@parsed_input)
      @section.stub(:singular => true)
      @section.parse( :input => @input, :output => @output )
      @output.should == { :body => @parsed_input }      
    end

    it "keeps an array of processed rows" do
      @section.should_receive(:process_record).and_return(@parsed_input)
      @section.should_receive(:process_record).and_return('more parsed stuff')
      @section.parse(:input => @input, :output => @output)
      @output.should == { :body => [@parsed_input, 'more parsed stuff'] }      
    end

    describe "error handling" do
      it "raises an error if now rows" do
        @section.stub(:optional => nil)
        lambda { @section.parse(:input => @input, :output => @output) }.should raise_error(FixedWidthMultirecord::RequiredSectionNotFoundError)
      end

      it "ignores empty rows if this section is optional" do
        lambda { @section.parse(:input => @input, :output => @output) }.should_not raise_error
      end
    end
  end

  describe "#format" do
    it "calls the first_line_parser formatter" do
      @section.first_line_parser.should_receive(:format).with(:ignore => :this).and_return("a line")
      @section.format(:ignore => :this)
    end

    it "returns an array" do
      @section.first_line_parser.stub(:format => "a line")
      @section.format({}).should == ["a line"]
    end

    it "handles multi-line records" do
      @section.first_line_parser.stub(:format => "first line")
      data = {:line2 => { :key1 => :value1, :key2 => :value2 }}
       
      mock_section = mock(FixedWidthMultirecord::Section, :short_name => :line2)
      @section.instance_variable_set('@additional_lines', [mock_section])
      mock_section.should_receive(:format).with(data[:line2]).and_return("another line")

      @section.format(data).should == ["first line", "another line"]
    end
  end

  describe "#process_record" do
    it "calls @first_line_parser#parse" do
      input = mock('input')
      @section.first_line_parser.should_receive(:parse).with(input).and_return(nil)
      @section.send(:process_record, input)
    end

    it "iterates across all the potential subrecords"  do
      input = mock('input')
      @section.first_line_parser.stub(:parse => {:a => :b})

      @section.instance_variable_set('@additional_lines', [mock('section1'), mock('section2')])
      @section.additional_lines.each do |l| 
        l.stub(:parse => nil) 
        l.should_receive(:parse).with(:input => input, :output => {:a => :b}).and_return(true)
      end

      @section.send(:process_record, input)
    end

    it "returns nil if parse fails" do
      input = mock('input')
      @section.first_line_parser.should_receive(:parse).with(input).and_return(nil)
      @section.send(:process_record, input).should == nil
    end

    it "returns a new record" do
      input = mock('input')
      @section.first_line_parser.should_receive(:parse).with(input).and_return({:a_record => :of_data})
      @section.send(:process_record, input).should == {:a_record => :of_data}
    end
  end
end
