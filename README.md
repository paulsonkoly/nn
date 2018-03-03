# Nn

Implementing neural networks, to recognize the MINST data set following the online book from http://neuralnetworksanddeeplearning.com.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nn'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nn

## Usage

Download the [MNIST data set](http://yann.lecun.com/exdb/mnist/) and place the following files under the project root: 'train-images-idx3-ubyte', 'train-labels-idx1-ubyte'.

You can start `bin/console` which loads the data set and predifines @net variable. An example session might look like:

```
pry(main)> i = Image.read_from_files(datafile: 'train-images-idx3-ubyte', labelfile: 'train-labels-idx1-ubyte', offset: 57500)
[44] pry(main)> i.data.each_slice(28) { |s| p s.map { |e| e > 0 ? 'X' : ' ' }.join }
"                            "
"                            "
"                            "
"         XXXXXX             "
"         XXXXXXXX           "
"         XXXXXXXXX          "
"         XXXXXXXXXX         "
"            XXXXXXX         "
"               XXXXX        "
"               XXXXX        "
"                XXXXX       "
"                 XXXX       "
"                 XXXX       "
"                  XXXX      "
"         XXXXXXXXXXXXX      "
"        XXXXXXXXXXXXXX      "
"        XXXXXXXXXXXXXX      "
"       XXXXXXXXXXXXXXX      "
"       XXXXX   XXXXXXX      "
"       XXXXXXXXXXXXXXX      "
"       XXXXXXXXXXXXXXX      "
"        XXXXXXXXXXXXXX      "
"        XXXXXXXXX           "
"                            "
"                            "
"                            "
"                            "
"                            "
[44] pry(main)> i.data.each_slice(28) { |s| p s.map { |e| e > 0 ? 'X' : ' ' }.join }
"                            "
"                            "
"                            "
"         XXXXXX             "
"         XXXXXXXX           "
"         XXXXXXXXX          "
"         XXXXXXXXXX         "
"            XXXXXXX         "
"               XXXXX        "
"               XXXXX        "
"                XXXXX       "
"                 XXXX       "
"                 XXXX       "
"                  XXXX      "
"         XXXXXXXXXXXXX      "
"        XXXXXXXXXXXXXX      "
"        XXXXXXXXXXXXXX      "
"       XXXXXXXXXXXXXXX      "
"       XXXXX   XXXXXXX      "
"       XXXXXXXXXXXXXXX      "
"       XXXXXXXXXXXXXXX      "
"        XXXXXXXXXXXXXX      "
"        XXXXXXXXX           "
"                            "
"                            "
"                            "
"                            "
"                            "
=> nil
[45] pry(main)> @net.feed_forward(Nn::Matrix.new(i.data)).map {|e| e.round(3) }
=> #<Nn::Matrix:0x00007f4f9c2515c8 @m=Matrix[[0.0], [0.0], [1.0], [0.001], [0.0], [0.0], [0.0], [0.0], [0.0], [0.0]]>
[46] pry(main)> i.value
=> 2
```

or to train the network

```
53] pry(main)> @net.sgd(@loader, 1, 3.0, @train_data)
Epoch 0 |====================================| 100% Time: 01:03:21 Time: 01:03:21
loader waited : 0, finished early : 24995
Epoch 0: 9497 / 10000
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
