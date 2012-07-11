require File.join(File.dirname(__FILE__), 'spec_helper')

describe FixedWidthMultirecord::Generator do
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
    @data = {
      :header => [ {:type => "HEAD", :file_id => "1" } ],
      :body => [ 
        {:first => "Paul", :last => "Hewson" },
        {:first => "Dave", :last => "Evans" }
      ],
      :footer => [ {:type => "FOOT", :file_id => "1" }]
    }
    @generator = FixedWidthMultirecord::Generator.new(@definition)
  end

  it "should raise an error if there is no data for a required section" do
    @data.delete :header
    lambda {  @generator.generate(@data) }.should raise_error(FixedWidthMultirecord::RequiredSectionEmptyError, "Required section 'header' was empty.")
  end

  it "should generate a string" do
    expected = "HEAD         1\n      Paul    Hewson\n      Dave     Evans\nFOOT         1\n"
    @generator.generate(@data).should == expected
  end
  
  it "should handle lazy data declaration (no array around single record for a section)" do
    expected = "HEAD         1\n      Paul    Hewson\n      Dave     Evans\nFOOT         1\n"
    @data[:header] = @data[:header].first
    @generator.generate(@data).should == expected
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
          b.line :credit_card, :optional => true do |cc|
            cc.trap { |line| line[0,4] == 'CARD' }
            cc.type 4
            cc.number 16
            cc.spacer 1
            cc.expires 4
          end
        end
        d.footer(:singular => true) do |f|
          f.trap { |line| line[0,4] == 'FOOT' }
          f.column :type, 4
          f.column :file_id, 10
        end
      end
      @generator = FixedWidthMultirecord::Generator.new(@definition)
    end

    describe "multi-line records" do 
      before(:each) do
        @expected_rows = [
          "HEAD         1\n",
          "BODY      Paul    Hewson\n",
          "CARD1234567812345678 0804\n",
          "CARD2345678123456781 0807\n",
          "BODY      Dave     Evans\n",
          "ADDR  1234 Main St01002\n",
          "FOOT         1\n"
        ]

        @expected = @expected_rows.join
      end

      it "handles multi-line records" do

        data = {
          :header => {:type => "HEAD", :file_id => "1" },
          :body => [ 
            {:type => "BODY", :first => "Paul", :last => "Hewson", :credit_card => [{:type => "CARD", :number => "1234567812345678", :expires => "0804"},{:type => "CARD", :number => "2345678123456781", :expires => "0807"}]},
            {:type => "BODY", :first => "Dave", :last => "Evans", :address_record => {:type => "ADDR", :street => "1234 Main St", :zip => "01002" }}
          ],
            :footer => {:type => "FOOT", :file_id => "1" }
        }

        @generator.generate(data).should == @expected
      end

      it "ensures that generate/parse are complements of each other" do
        data = FixedWidthMultirecord.parse(mock(File, :readlines => @expected_rows), :test) 
        @generator.generate(data).should == @expected
      end
    end
  end

end
