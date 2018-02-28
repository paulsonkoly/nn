require 'bindata'
require_relative 'image/reader'

class Image
  attr_reader :number_of_rows, :number_of_columns
  attr_reader :data, :value

  def initialize(number_of_rows:, number_of_columns:, data:, value:)
    @number_of_rows = number_of_rows
    @number_of_columns = number_of_columns
    @data = data
    @value = value
  end

  def self.read_from_files(datafile:, labelfile:, offset: 0)
    hdr, data = Reader::DataReader.new(datafile).read(offset)
    __, label = Reader::LabelReader.new(labelfile).read(offset)
    Image.new(number_of_rows: hdr.number_of_rows,
              number_of_columns: hdr.number_of_columns,
              data: data,
              value: label)
  end
end
