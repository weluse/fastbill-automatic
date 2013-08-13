# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = "fastbill-automatic"
  spec.version       = FastbillAutomatic::VERSION
  spec.authors       = ["Markus Krebber", "Raphael Randschau"]
  spec.email         = ["mkrebber@weluse.de", "rrandschau@weluse.de"]
  spec.description   = %q{fastbill automatic api client}
  spec.summary       = %q{fastbill automatic api client}
  spec.homepage      = "http://weluse.de"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "minitest", "~> 5.0.6"
  spec.add_development_dependency "guard-minitest"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_development_dependency "mocha", "~> 0.14.0"
  spec.add_dependency "typhoeus", "~> 0.6.4"
end
