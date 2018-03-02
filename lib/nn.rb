require "nn/version"
require 'matrix/matrix_stdlib'
require 'ruby-progressbar'

module Nn
  class Network
    # @param sizes Contains the number of neurons in the respective layers.
    def initialize(*sizes)
      @num_layers = sizes.length
      @sizes = sizes
      @biases = sizes[1..-1].map { |s| Matrix.random([s, 1]) }
      @weights = sizes.each_cons(2).map { |a, b| Matrix.random([b, a]) }
    end

    # Calculates the result of the neural network
    #
    # @param input [NMatrix[Numeric]] The network input.
    # @return [Nmatrix[Numeric]] The network output.
    def feed_forward(input)
      @biases.zip(@weights).each do |b, w|
        input = w.dot(input) + b
        input = input.map(&method(:sigmoid))
      end
      input
    end

    # Train the neural network using mini-batch stochastic gradient descent.
    #
    # @param training_data [Array[[input, result]] a list of tuples
    # representing the training inputs and the desired outputs.
    # @param epochs [Integer] Number of epochs to run.
    # @param mini_batch_size [Integer] Size of each batch to execute gradient
    # descent on.
    # @param eta Sampling rate.
    # @param test_data [Array[[input, result]]|nil] If provided then the
    # network will be evaluated against the test data after each epoch, and
    # partial progress printed out. This is useful for tracking progress, but
    # slows things down substantially.
    def sgd(loader, epochs, eta, test_data = nil)
      epochs.times do |epoch|
        loader.shuffle!
        loader.each { |mini_batch| update_mini_batch(mini_batch, eta) }
        if test_data
          p "Epoch #{epoch}: #{evaluate(test_data)} / #{test_data.length}"
        end
      end
    end

    private

    def sigmoid(num)
      1.0/(1.0+Math::exp(-num))
    end

    # Derivative of the sigmoid function.
    def sigmoid_prime(z)
      sigmoid(z)*(1-sigmoid(z))
    end

    # Update the network's weights and biases by applying gradient descent
    # using backpropagation to a single mini batch.
    #
    # @param mini_batch A list of tuples "(x, y)"
    # @param eta The learning rate.
    def update_mini_batch(mini_batch, eta)
      nabla_b = @biases.map { |b| Matrix.zeros(b.shape) }
      nabla_w = @weights.map { |w| Matrix.zeros(w.shape) }
      eta = eta / mini_batch.length

      mini_batch.each do |(input, value)|
        delta_nabla_b, delta_nabla_w = backprop(input, value)

        nabla_b.map!.with_index { |b, ix| b + delta_nabla_b[ix] }
        nabla_w.map!.with_index { |w, ix| w + delta_nabla_w[ix] }
      end

      @weights.map!.with_index { |w, ix| w - nabla_w[ix] * eta }
      @biases.map!.with_index { |b, ix| b - nabla_b[ix] * eta }
    end

    # The gradient of the cost function
    # @param input An input elem
    # @param value The expected result
    # @return Pair of bias, weight gradient vectors
    def backprop(input, value)
      nabla_b = @biases.map { |b| Matrix.zeros(b.shape) }
      nabla_w = @weights.map { |w| Matrix.zeros(w.shape) }

      # feedforward
      activation = input
      activations = [input] # list to store all the activations, layer by layer
      zs = [] # list to store all the z vectors, layer by layer
      @biases.zip(@weights) do |b, w|
        z = w.dot(activation) + b
        zs << (z)
        activation = z.map(&method(:sigmoid))
        activations << activation
      end

      # backward pass
      delta = cost_derivative(activations[-1], value) *
        zs[-1].map(&method(:sigmoid_prime))
      nabla_b[-1] = delta
      nabla_w[-1] = delta.dot(activations[-2].transpose)
      # Note that the variable l in the loop below is used a little
      # differently to the notation in Chapter 2 of the book.  Here,
      # l = 1 means the last layer of neurons, l = 2 is the
      # second-last layer, and so on.  It's a renumbering of the
      # scheme in the book, used here to take advantage of the fact
      # that Python can use negative indices in lists.
      (2...@num_layers).each do |ix|
        z = zs[-ix]
        sp = z.map(&method(:sigmoid_prime))
        delta = @weights[-ix+1].transpose.dot(delta) * sp
        nabla_b[-ix] = delta
        nabla_w[-ix] = delta.dot(activations[-ix-1].transpose())
      end
      [ nabla_b, nabla_w ]
    end


    # Return the number of test inputs for which the neural network outputs the
    # correct result. Note that the neural network's output is assumed to be
    # the index of whichever neuron in the final layer has the highest
    # activation.
    def evaluate(test_data)
      test_data.count do |input, value|
        a = feed_forward(input).to_a
        a.each_with_index.max[1] == value
      end
    end

    # Return the vector of partial derivatives d C_x / d a for the output activations.
    def cost_derivative(output_activations, y)
      output_activations-y
    end
  end
end
