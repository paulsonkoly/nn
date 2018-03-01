require "nn/version"

require 'nmatrix'

module Nn
  class Network
    # @param sizes Contains the number of neurons in the respective layers.
    def initialize(*sizes)
      @num_layers = sizes.length
      @sizes = sizes
      @biases = sizes[1..-1].map { |s| NMatrix.random([s, 1]) }
      @weights = sizes.each_cons(2).map { |a, b| NMatrix.random(a, b) }
    end
  end
end
