require File.join(File.dirname(__FILE__), 'spec_helper')

describe FixedWidthMultirecord do

  before(:each) do
    @name = :doc
    @options = { :align => :left }
  end

  describe "when defining a format" do
    before(:each) do
      @definition = mock('definition')
    end

    it "should create a new definition using the specified name and options" do
      FixedWidthMultirecord.should_receive(:define).with(@name, @options).and_return(@definition)
      FixedWidthMultirecord.define(@name , @options)
    end

    it "should pass the definition to the block" do
      yielded = nil
      FixedWidthMultirecord.define(@name) do |y|
        yielded = y
      end
      yielded.should be_a( FixedWidthMultirecord::Definition )
    end

    it "should add to the internal definition count" do
      FixedWidthMultirecord.definitions.clear
      FixedWidthMultirecord.should have(0).definitions
      FixedWidthMultirecord.define(@name , @options) {}
      FixedWidthMultirecord.should have(1).definitions
    end
  end

  describe "when creating file from data" do 
    it "should raise an error if the definition name is not found" do
      lambda { FixedWidthMultirecord.generate(:not_there, {}) }.should raise_error(ArgumentError)
    end

    it "should output a string" do
      definition = mock('definition')
      generator = mock('generator')
      generator.should_receive(:generate).with({})
      FixedWidthMultirecord.should_receive(:definition).with(:test).and_return(definition)
      FixedWidthMultirecord::Generator.should_receive(:new).with(definition,"\n").and_return(generator)
      FixedWidthMultirecord.generate(:test, {})
    end

    it "should output a file" do
      file = mock('file')
      text = mock('string')
      file.should_receive(:write).with(text)
      FixedWidthMultirecord.should_receive(:generate).with(:test, {}).and_return(text)
      FixedWidthMultirecord.write(file, :test, {})
    end
  end

  describe "when parsing a file" do
    before(:each) do
      @file = mock('file')
    end

    it "should check the file exists" do
      lambda { FixedWidthMultirecord.parse(@file, :test, {}) }.should raise_error(ArgumentError)
    end

    it "should raise an error if the definition name is not found" do
      FixedWidthMultirecord.definitions.clear
      lambda { FixedWidthMultirecord.parse(@file, :test, {}) }.should raise_error(ArgumentError)
    end

    it "should create a parser and call parse" do
      parser = mock("parser").as_null_object
      definition = mock('definition')
      FixedWidthMultirecord.should_receive(:definition).with(:test).and_return(definition)
      FixedWidthMultirecord::Parser.should_receive(:new).with(definition, @file).and_return(parser)
      FixedWidthMultirecord.parse(@file, :test)
    end
  end
end
