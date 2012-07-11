require File.join(File.dirname(__FILE__), 'spec_helper')

describe FixedWidthMultirecord::Definition do
  describe "when specifying alignment" do
    it "should have an alignment option" do
      d = FixedWidthMultirecord::Definition.new :align => :right
      d.options[:align].should == :right
    end

    it "should default to being right aligned" do
      d = FixedWidthMultirecord::Definition.new
      d.options[:align].should == :right
    end

    it "should override the default if :align is passed to the section" do
      section = mock('section').as_null_object
      d = FixedWidthMultirecord::Definition.new
      FixedWidthMultirecord::Section.should_receive(:new).with('name', {:align => :left, :definition => d}).and_return(section)
      d.options[:align].should == :right
      d.section('name', :align => :left) {}
    end
  end

  describe "when creating a section" do
    before(:each) do
      @d = FixedWidthMultirecord::Definition.new
      @section = mock('section').as_null_object
    end

    it "should create a new section object" do
      yielded = nil
      @d.section :header do |section|
        yielded = section
      end
      yielded.should be_a(FixedWidthMultirecord::Section)
      @d.sections.first.should == yielded
    end

    it "should magically build a section from an unknown method" do
      FixedWidthMultirecord::Section.should_receive(:new).with(:header, anything()).and_return(@section)
      @d.header {}
    end

    it "should not create duplicate section names" do
      lambda { @d.section(:header) {} }.should_not raise_error(FixedWidthMultirecord::DuplicateSectionNameError)
      lambda { @d.section(:header) {} }.should raise_error(FixedWidthMultirecord::DuplicateSectionNameError, "Duplicate section name: 'header'")
    end
  end

  describe "when creating a template" do
    before(:each) do
      @d = FixedWidthMultirecord::Definition.new
      @section = mock('section').as_null_object
    end

    it "should create a new section" do
      FixedWidthMultirecord::Section.should_receive(:new).with(:row, anything()).and_return(@section)
      @d.template(:row) {}
    end

    it "add a section to the templates collection" do
      @d.should have(0).templates
      @d.template :row do |t|
        t.column :id, 3
      end
      @d.should have(1).templates
      @d.templates[:row].should be_a(FixedWidthMultirecord::Section)
    end
  end
end
