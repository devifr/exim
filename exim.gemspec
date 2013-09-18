# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'exim/version'

Gem::Specification.new do |spec|
  spec.name          = "exim"
  spec.version       = Exim::VERSION
  spec.authors       = ["Devi Firdaus"]
  spec.email         = ["dfedogawa3@gmail.com"]
  spec.description   = "for import or export file"
  spec.summary       = "first time in create for api grape"
  spec.homepage      = "https://github.com/devifr"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "nokogiri"
  spec.add_development_dependency "rubyzip", "0.9.9"
  spec.add_development_dependency "spreadsheet", "~> 0.6.4"
end
