require File.join(File.dirname(__FILE__), 'spec_helper')

describe FixedWidth::LineParser do
  before(:each) do
    @lp = FixedWidth::LineParser.new(:name => :a_parser)
  end

  describe "#initialize" do
    it "should have no columns after creation" do
      @lp.columns.should be_empty
    end
  end

  describe "when adding columns" do
    it "should build an ordered column list" do
      @lp.should have(0).columns

      col1 = @lp.column :id, 10
      col2 = @lp.column :name, 30
      col3 = @lp.column :state, 2

      @lp.should have(3).columns
      @lp.columns[0].should be(col1)
      @lp.columns[1].should be(col2)
      @lp.columns[2].should be(col3)
    end

    it "should create spacer columns" do
      @lp.should have(0).columns
      @lp.spacer(5)
      @lp.should have(1).columns
    end

    it "should use a missing method to create a column" do
      @lp.should have(0).columns
      @lp.first_name 5
      @lp.should have(1).columns
    end

    it "should prevent duplicate column names without any groupings" do
      @lp.column :id, 10
      lambda { @lp.column(:id, 30) }.should raise_error(FixedWidth::DuplicateColumnNameError, /column named 'id'/)
    end

    it "should prevent column names that already exist as groups" do
      @lp.column :foo, 11, :group => :id
      lambda { @lp.column(:id, 30) }.should raise_error(FixedWidth::DuplicateGroupNameError, /group named 'id'/)
    end

    it "should prevent group names that already exist as columns" do
      @lp.column :foo, 11
      lambda { @lp.column(:id, 30, :group => :foo) }.should raise_error(FixedWidth::DuplicateGroupNameError, /column named 'foo'/)
    end

    it "should prevent duplicate column names within groups" do
      @lp.column :id, 10, :group => :foo
      lambda { @lp.column(:id, 30, :group => :foo) }.should raise_error(FixedWidth::DuplicateColumnNameError, /column named 'id' in the ':foo' group/)
    end

    it "should allow duplicate column names in different groups" do
      @lp.column :id, 10, :group => :foo
      lambda { @lp.column(:id, 30, :group => :bar) }.should_not raise_error(FixedWidth::DuplicateColumnNameError)
    end

    it "should allow duplicate column names that are reserved (i.e. spacer)" do
      @lp.spacer 10
      lambda { @lp.spacer 10 }.should_not raise_error(FixedWidth::DuplicateColumnNameError)
    end
  end

  it "should accept and store the trap as a block" do
    @lp.trap { |v| v == 4 }
    trap = @lp.instance_variable_get(:@trap)
    trap.should be_a(Proc)
    trap.call(4).should == true
  end

  describe "when adding a template" do
    before(:each) do
      @template = mock('templated section', :columns => [1,2,3], :options => {})
      @definition = mock("definition", :templates => { :test => @template } )
      @lp.options[:definition] = @definition
    end

    it "should ensure the template exists" do
      @definition.stub(:templates => {})
      lambda { @lp.template(:none) {} }.should raise_error(ArgumentError)
    end

    it "should add the template columns to the current column list" do
      @lp.template(:test) {}
      @lp.should have(3).columns
    end

    it "should merge the template option" do
      @lp.options[:align] = :left
      @template.stub(:options => {:align => :right, :other_option => :value})
      @lp.template(:test) {}
      @lp.options.should == {:name => :a_parser, :align => :left, :definition => @definition, :other_option => :value}
    end
  end

  describe "outputting data" do
    describe "#format" do
      before(:each) do
        @data = { :id => 3, :name => "Ryan" }
      end

      it "should default to string data aligned right" do
        @lp.column(:id, 5)
        @lp.column(:name, 10)
        @lp.format(@data).should == "    3      Ryan"
      end

      it "should left align if asked" do
        @lp.column(:id, 5)
        @lp.column(:name, 10, :align => :left)
        @lp.format(@data).should == "    3Ryan      "
      end

      it "should read from groups" do
        @data = { :id => 3, :foo => { :name => "Ryan" } }
        @lp.column(:id, 5)
        @lp.column(:name, 10, :align => :left, :group => :foo)
        @lp.format(@data).should == "    3Ryan      "
      end
    end
  end

  describe "parsing a line" do
    before(:each) do
      @line = ['   45      Ryan      WoodSC ']
      @column_content = { :id => 5, :first => 10, :last => 10, :state => 2 }
      @column_content.each { |k,v| @lp.column(k, v) }
      @lp.trap {true}
    end

    it "should return a key for key column" do
      output = @lp.parse(@line)
      @column_content.each_key { |name| output.should have_key(name) }
    end

    it "should not return a key for reserved names" do
      @lp.spacer 5
      @lp.should have(5).columns
      parsed = @lp.parse(@line)
      parsed.should have(4).keys
    end

    it "should break columns into groups" do
      lp = FixedWidth::LineParser.new 
      lp.column(:id, 5)
      lp.column(:first, 10, :group => :name)
      lp.column(:last, 10, :group => :name)
      lp.column(:state, 2, :group => :address)
      lp.spacer 5
      lp.trap {true}
      lp.should have(5).columns
      parsed = lp.parse(@line)
      parsed.should have(3).keys
      parsed[:id].should == '45'
      parsed[:name][:first].should == 'Ryan'
      parsed[:name][:last].should == 'Wood'
      parsed[:address][:state].should == 'SC'
    end

    it "should try to match a line using the trap" do
      @lp.trap do |line|
        line == 'hello'
      end
      @lp.match('hello').should be_true
      @lp.match('goodbye').should be_false
    end
  end
end
