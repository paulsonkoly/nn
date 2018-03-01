require "nn/version"

require 'nmatrix'

module Nn
  class Network
    # @param sizes Contains the number of neurons in the respective layers.
    def initialize(*sizes)
      @num_layers = sizes.length
      @sizes = sizes
      @biases = sizes[1..-1].map { |s| NMatrix.random([s, 1]) }
      @weights = sizes.each_cons(2).map { |a, b| NMatrix.random([b, a]) }
    end

    # Calculates the result of the neural network
    #
    # @param input [NMatrix[Numeric]] The network input.
    # @return [Nmatrix[Numeric]] The network output.
    def feed_forward(input)
      @biases.zip(@weights).each do |b, w|
        pp w: w.shape, input: input.shape
        input = w.dot(input) + b
        input = input.map(&method(:sigmoid))
      end
      input
    end

    private

    def sigmoid(num)
      1.0/(1.0+Math::exp(-num))
    end
  end
end
