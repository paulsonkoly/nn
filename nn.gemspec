
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "nn/version"

Gem::Specification.new do |spec|
  spec.name          = "nn"
  spec.version       = Nn::VERSION
  spec.authors       = ["Paul Sonkoly"]
  spec.email         = ["sonkoly.pal@gmail.com"]

  spec.summary       = %q{Neural Network Library / Exercise implementation}
  spec.description   = %q{Implementing neural networks, to recognize the MINST
  data set following the online book from
  http://neuralnetworksanddeeplearning.com. }
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_runtime_dependency 'bindata', '~> 2.4.0'
#  spec.add_runtime_dependency 'nmatrix', '~> 0.2'
end
