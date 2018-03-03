require 'matrix'
require 'forwardable'

# Since at the moment the faster NMatrix library has issues, I decided to use
# the built in matrix instead. This shim should hide which library we are
# using.
module Nn
  class Matrix
    def initialize(m)
      case m
      when ::Matrix
        @m = m
      else
        @m = ::Matrix[*(m.map { |e| [e] })]
      end
    end

    def map(&block)
      Matrix.new(@m.map(&block))
    end

    def dot(other)
      Matrix.new(@m * other.instance_variable_get(:@m))
    end

    def transpose
      Matrix.new(@m.transpose)
    end

    def to_a
      @m.to_a.flatten
    end

    [[:+], [:-], [:*, :hadamard_product]].each do |op, proxy_op = op|
      define_method(op) do |other|
        case other
        when self.class
          Matrix.new(@m.send(proxy_op, other.instance_variable_get(:@m)))
        else
          Matrix.new(@m.map { |e| e.send(op, other) })
        end
      end
    end

    def shape
      [@m.row_count, @m.column_count]
    end

    def self.random(shape)
      Matrix.new(::Matrix.build(*shape) { 2 * rand - 1.0 })
    end

    def self.zeros(shape)
      Matrix.new(::Matrix.build(*shape) { 0 })
    end
  end
end
