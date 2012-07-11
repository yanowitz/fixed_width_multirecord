require File.join(File.dirname(__FILE__), 'spec_helper')

describe FixedWidthMultirecord::Parser do
  before(:each) do
    @definition = mock('definition', :sections => [])
    @file = mock("file")
    @parser = FixedWidthMultirecord::Parser.new(@definition, @file)
  end

  it "should read in a source file" do
    @file.should_receive(:readlines).and_return(["\n"])
    @parser.parse
  end

  describe "when parsing sections" do
    before(:each) do
      @definition = FixedWidthMultirecord.define :test do |d|
        d.header do |h|
          h.trap { |line| line[0,4] == 'HEAD' }
          h.column :type, 4
          h.column :file_id, 10
        end
        d.body do |b|
          b.trap { |line| line[0,4] =~ /[^(HEAD|FOOT)]/ }
          b.column :first, 10
          b.column :last, 10
        end
        d.footer do |f|
          f.trap { |line| line[0,4] == 'FOOT' }
          f.column :type, 4
          f.column :file_id, 10
        end
      end
      @parser = FixedWidthMultirecord::Parser.new(@definition, @file)
    end

    it "should add lines to the proper sections" do
      @file.should_receive(:readlines).and_return([
        "HEAD         1\n",
        "      Paul    Hewson\n",
        "      Dave     Evans\n",
        "FOOT         1\n"
      ])
      expected = {
        :header => [ {:type => "HEAD", :file_id => "1" } ],
        :body => [ 
          {:first => "Paul", :last => "Hewson" },
          {:first => "Dave", :last => "Evans" }
        ],
        :footer => [ {:type => "FOOT", :file_id => "1" } ]
      }
      result = @parser.parse
      result.should == expected
    end

    describe "multi-line records" do
      before(:each) do
        @definition = FixedWidthMultirecord.define :test do |d|
          d.header(:singular => true) do |h|
            h.trap { |line| line[0,4] == 'HEAD' }
            h.column :type, 4
            h.column :file_id, 10
          end
          d.body do |b|
            b.trap { |line| line[0,4] == 'BODY' }
            b.column :type, 4
            b.column :first, 10
            b.column :last, 10
            b.line :address_record, :optional => true, :singular => true do |ar|
             ar.trap { |line| line[0,4] == 'ADDR' }
             ar.type 4
             ar.street 14
             ar.zip 5
            end
          end
          d.footer(:singular => true) do |f|
            f.trap { |line| line[0,4] == 'FOOT' }
            f.column :type, 4
            f.column :file_id, 10
          end
        end
        @parser = FixedWidthMultirecord::Parser.new(@definition, @file)
      end

      it "handles nested lines" do
        @file.should_receive(:readlines).and_return([
          "HEAD         1\n",
          "BODY  Paul    Hewson\n",
          "BODY  Dave     Evans\n",
          "ADDR1234 Main St  01002\n",
          "FOOT         1\n"
        ])
        expected = {
          :header => {:type => "HEAD", :file_id => "1" },
          :body => [ 
            {:type => "BODY", :first => "Paul", :last => "Hewson" },
            {:type => "BODY", :first => "Dave", :last => "Evans", :address_record => {:type => "ADDR", :street => "1234 Main St", :zip => "01002" }}
          ],
            :footer => {:type => "FOOT", :file_id => "1" }
        }
        result = @parser.parse
        result.should == expected
      end
    end

    it "should treat singular sections properly" do
      @definition = FixedWidthMultirecord.define :test do |d|
        d.header(:singular => true) do |h|
          h.trap { |line| line[0,4] == 'HEAD' }
          h.column :type, 4
          h.column :file_id, 10
        end
        d.body do |b|
          b.trap { |line| line[0,4] =~ /[^(HEAD|FOOT)]/ }
          b.column :first, 10
          b.column :last, 10
        end
        d.footer(:singular => true) do |f|
          f.trap { |line| line[0,4] == 'FOOT' }
          f.column :type, 4
          f.column :file_id, 10
        end
      end
      @parser = FixedWidthMultirecord::Parser.new(@definition, @file)
      @file.should_receive(:readlines).and_return([
        "HEAD         1\n",
        "      Paul    Hewson\n",
        "      Dave     Evans\n",
        "FOOT         1\n"
      ])
      expected = {
        :header => {:type => "HEAD", :file_id => "1" },
        :body => [
          {:first => "Paul", :last => "Hewson" },
          {:first => "Dave", :last => "Evans" }
        ],
        :footer => {:type => "FOOT", :file_id => "1" }
      }
      result = @parser.parse
      result.should == expected
    end

    it "should allow optional sections to be skipped" do
      @definition.sections[0].optional = true
      @definition.sections[2].optional = true
      @file.should_receive(:readlines).and_return([
        "      Paul    Hewson\n"
      ])
      expected = { :body => [ {:first => "Paul", :last => "Hewson" } ] }
      @parser.parse.should == expected
    end

    it "should raise an error if a required section is not found" do
      @file.should_receive(:readlines).and_return([
        "      Ryan      Wood\n"
      ])
      lambda { @parser.parse }.should raise_error(FixedWidthMultirecord::RequiredSectionNotFoundError, "Required section 'header' was not found.")
    end
  end
end
