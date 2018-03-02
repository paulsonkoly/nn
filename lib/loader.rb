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
      @wait_count = 0
      @finished_count = 0

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
      0.step(to: @total_size - @batch_size, by: @batch_size) do |progress|
        data = load_up(progress)
        wait_on future
        future = Concurrent::Future.execute { yield(data) }
        bar.progress = progress
      end
      bar.finish
      @epoch += 1
    end

    def stats
      "loader waited : #{@wait_count}, finished early : #{@finished_count}"
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

    def wait_on(future)
      if future
        if future.pending?
          @wait_count += 1
          future.wait
        else
          @finished_count += 1
        end
      end
    end
  end
end
