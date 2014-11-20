# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jq/version'

Gem::Specification.new do |spec|
  spec.name          = "ruby-jq"
  spec.version       = JQ::VERSION
  spec.author        = "winebarrel"
  spec.email         = "sgwr_dts@yahoo.co.jp"
  spec.description   = "Ruby bindings for jq"
  spec.summary       = "Ruby bindings for jq"
  spec.homepage      = "https://github.com/winebarrel/ruby-jq"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.extensions    = "ext/extconf.rb"
  #spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  #spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "json"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rake-compiler"
  spec.add_development_dependency "rspec"
end
