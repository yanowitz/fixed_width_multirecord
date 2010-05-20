DESCRIPTION:
============

A simple, clean DSL for describing, writing, and parsing fixed-width text files.

FEATURES:
=========

* Easy DSL syntax
* Can parse and format fixed width files
* Templated sections for reuse

SYNOPSIS:
=========

    # Create a FixedWidth::Defintion to describe a file format
    FixedWidth.define :simple do |d|

      # This is a template section that can be reused in other sections
      d.template :boundary do |t|
        t.column :record_type, 4
        t.column :company_id, 12
      end

      # Create a header section
      d.header, :align => :left do |header|
        # The trap tells FixedWidth which lines should fall into this section
        header.trap { |line| line[0,4] == 'HEAD' }
        # Use the boundary template for the columns
        header.template :boundary
      end

      d.body do |body|
        body.trap { |line| line[0,4] =~ /[^(HEAD|FOOT)]/ }
        body.column :id, 10, :parser => :to_i
        body.column :name, 10, :align => :left
        body.spacer 3
        body.column :state, 2
      end

      d.footer do |footer|
        footer.trap { |line| line[0,4] == 'FOOT' }
        footer.template :boundary
        footer.column :record_count, 10
      end
    end

`:parser` and `:formatter` options are symbols (to be proc-ified) or procs. By default, parsing and formatting assume that we're expecting/writing right-aligned strings, padded with spaces.

Then either feed it a nested struct with data values to create the file in the defined format:

    test_data = {
      :body => [
        { :id => 12, :name => "Ryan", :state => 'SC' },
        { :id => 23, :name => "Joe", :state => 'VA' },
        { :id => 42, :name => "Tommy", :state => 'FL' },
      ],
      :header => { :record_type => 'HEAD', :company_id => 'ABC'  },
      :footer => { :record_type => 'FOOT', :company_id => 'ABC'  }
    }

    # Generates the file as a string
    puts FixedWidth.generate(:simple, test_data)

    # Writes the file
    FixedWidth.write('outfile.txt', :simple, test_data)

Or parse files already in that format into a nested hash:

    parsed_data = FixedWidth.parse('infile.txt', :test).inspect

INSTALL:
========

    sudo gem install fixed_width