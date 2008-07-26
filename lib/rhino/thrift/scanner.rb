module Rhino
  module ThriftInterface
    class Scanner
      include Enumerable
      
      attr_reader :htable
      
      def initialize(htable, opts={})
        @htable = htable
        @opts = opts
        @opts[:start] ||= ''
        @opts[:columns] ||= self.htable.column_families
        
        
        open_scanner
      end
      
      def open_scanner
        # TODO: replace title: with actual columns
        @scanner = htable.hbase.scannerOpen(htable.table_name, @opts[:start], @opts[:columns])
      end
      
      # Returns the next row in the scanner in the format specified below. Note that the row key is 'key', not 'key:'.
      #   {'key'=>'the row key', 'col1:'=>'val1', 'col2:asdf'=>'val2'}
      def next_row
        begin
          row = htable.hbase.scannerGet(@scanner)
          return row.columns.merge('key'=>row.row)
        rescue Apache::Hadoop::Hbase::Thrift::NotFound
          htable.hbase.scannerClose(@scanner)
          return nil
        end
      end
      
      def each
        while row = next_row()
          yield(row)
        end
      end
    end
  end
end