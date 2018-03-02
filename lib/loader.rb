require 'image'
require 'matrix/matrix_stdlib'
require 'concurrent'

module Nn
  class Loader
    include Enumerable

    def initialize(datafile:, labelfile:, total_size:, batch_size:)
      @datafile = datafile
      @labelfile = labelfile
      @total_size = total_size
      @batch_size = batch_size
      @epoch = 0

      @mapping = (0 ... total_size).entries
    end

    def shuffle!
      @mapping.shuffle!
    end

    def each
      return to_enum :each unless block_given?
      bar = ProgressBar.create format: "Epoch #{@epoch} |%B| %p%"
      bar.total = @total_size
      future = nil
      0.step(@total_size, @batch_size) do |progress|
        data = load_up(progress)
        future.wait if future
        future = Concurrent::Future.execute { yield(data) }
        bar.progress = progress
      end
      @epoch += 1
    end

    private

    def load_up(progress)
      @mapping[progress, @batch_size].map do |offset|
        image = Image.read_from_files(datafile:@datafile,
                                      labelfile: @labelfile,
                                      offset: offset)
        v = Array.new(10) { 0 }
        v[image.value] = 1.0
        [Matrix.new(image.data), Matrix.new(v)]
      end
    end
  end
end
