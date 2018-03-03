class Image
  # @private
  module Reader
    class Reader
      def initialize(filename)
        @filename = filename
      end

      # Forwards the header block DSL to BinData record definition. Use this in
      # the sub classes to specify the file header layout.
      def self.header(&block)
        raise ArgumentError unless block_given?

        klass = @klass = Class.new(BinData::Record)
        @klass.class_eval(&block)

        define_method(:read_header) do |io, offset|
          hdr = klass.read(io)
          raise 'Image is out of bounds' unless offset < hdr.number_of_items
          hdr
        end
      end

      def read(offset)
        File.open(@filename, 'rb') do |io|
          hdr = read_header(io, offset)
          io.pos = hdr.num_bytes + offset * item_size(hdr)
          item = read_item(hdr, io)
          [hdr, item]
        end
      end
    end

    class DataReader < Reader
      header do
        uint32be :magic_number, assert: 2051
        uint32be :number_of_items
        uint32be :number_of_rows
        uint32be :number_of_columns
      end

      def item_size(hdr)
        hdr.number_of_rows * hdr.number_of_columns
      end

      def read_item(hdr, io)
        size = self.item_size(hdr)
        data = BinData::Array.new(type: :uint8,
                                  read_until: -> { index + 1 == size }).read(io)
        data.map { |e| e / 255.0 }
      end
    end

    class LabelReader < Reader
      header do
        uint32be :magic_number, assert: 2049
        uint32be :number_of_items
      end

      def item_size(hdr); 1; end
      def read_item(_, io); BinData::Uint8.new.read(io); end
    end
  end
end
