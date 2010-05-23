require File.join(File.dirname(__FILE__), 'spec_helper')

describe FixedWidth do

  before(:each) do
    @name = :doc
    @options = { :align => :left }
  end

  describe "when defining a format" do
    before(:each) do
      @definition = mock('definition')
    end

    it "should create a new definition using the specified name and options" do
      FixedWidth.should_receive(:define).with(@name, @options).and_return(@definition)
      FixedWidth.define(@name , @options)
    end

    it "should pass the definition to the block" do
      yielded = nil
      FixedWidth.define(@name) do |y|
        yielded = y
      end
      yielded.should be_a( FixedWidth::Definition )
    end

    it "should add to the internal definition count" do
      FixedWidth.definitions.clear
      FixedWidth.should have(0).definitions
      FixedWidth.define(@name , @options) {}
      FixedWidth.should have(1).definitions
    end
  end

  describe "when creating file from data" do 
    it "should raise an error if the definition name is not found" do
      lambda { FixedWidth.generate(:not_there, {}) }.should raise_error(ArgumentError)
    end

    it "should output a string" do
      definition = mock('definition')
      generator = mock('generator')
      generator.should_receive(:generate).with({})
      FixedWidth.should_receive(:definition).with(:test).and_return(definition)
      FixedWidth::Generator.should_receive(:new).with(definition).and_return(generator)
      FixedWidth.generate(:test, {})
    end

    it "should output a file" do
      file = mock('file')
      text = mock('string')
      file.should_receive(:write).with(text)
      FixedWidth.should_receive(:generate).with(:test, {}).and_return(text)
      FixedWidth.write(file, :test, {})
    end
  end

  describe "when parsing a file" do
    before(:each) do
      @file = mock('file')
    end

    it "should check the file exists" do
      lambda { FixedWidth.parse(@file, :test, {}) }.should raise_error(ArgumentError)
    end

    it "should raise an error if the definition name is not found" do
      FixedWidth.definitions.clear
      lambda { FixedWidth.parse(@file, :test, {}) }.should raise_error(ArgumentError)
    end

    it "should create a parser and call parse" do
      parser = mock("parser", :null_object => true)
      definition = mock('definition')
      FixedWidth.should_receive(:definition).with(:test).and_return(definition)
      FixedWidth::Parser.should_receive(:new).with(definition, @file).and_return(parser)
      FixedWidth.parse(@file, :test)
    end
  end
end
