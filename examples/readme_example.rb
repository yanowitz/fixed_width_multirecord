require 'stringio'
require File.join(File.dirname(__FILE__), "..", "lib", "fixed_width")

# Create a FixedWidth::Defintion to describe a file format
FixedWidth.define :simple do |d|
  # This is a template section that can be reused in other sections
  d.template :boundary do |t|
    t.column :record_type, 4
    t.column :company_id, 12
  end

  # Create a header section
  d.header(:align => :left) do |header|
    # The trap tells FixedWidth which lines should fall into this section
    header.trap { |line| line[0,4] == 'HEAD' }
    # Use the boundary template for the columns
    header.template :boundary
  end

  d.body do |body|
    body.trap { |line| line[0,4] =~ /[^(HEAD|FOOT)]/ }
    body.column :id, 10, :parser => :to_i
    body.column :first, 10, :align => :left, :group => :name
    body.column :last,  10, :align => :left, :group => :name
    body.spacer 3
    body.column :city, 20  , :group => :address
    body.column :state, 2  , :group => :address
    body.column :country, 3, :group => :address
  end

  d.footer do |footer|
    footer.trap { |line| line[0,4] == 'FOOT' }
    footer.template :boundary
    footer.column :record_count, 10, :parser => :to_i
  end
end

test_data = {
    :body => [
      { :id => 12,
        :name => { :first => "Ryan", :last => "Wood" },
        :address => { :city => "Foo", :state => 'SC', :country => "USA" }
      },
      { :id => 13,
        :name => { :first => "Jo", :last => "Schmo" },
        :address => { :city => "Bar", :state => "CA", :country => "USA" }
      }
    ],
    :header => [{ :record_type => 'HEAD', :company_id => 'ABC'  }],
    :footer => [{ :record_type => 'FOOT', :company_id => 'ABC', :record_count => 2  }]
}

# Generates the file as a string
generated = FixedWidth.generate(:simple, test_data)

sio = StringIO.new
sio.write(generated)
sio.rewind

parsed = FixedWidth.parse(sio, :simple)

puts parsed == test_data