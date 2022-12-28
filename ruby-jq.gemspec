# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'jq/version'

Gem::Specification.new do |spec|
  spec.name          = 'ruby-jq'
  spec.version       = JQ::VERSION
  spec.author        = 'winebarrel'
  spec.email         = 'sgwr_dts@yahoo.co.jp'
  spec.description   = 'Ruby bindings for jq, lightweight and flexible JSON processor'
  spec.summary       = 'Ruby bindings for jq'
  spec.homepage      = 'https://github.com/winebarrel/ruby-jq'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.extensions    = 'ext/extconf.rb'
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  # spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'multi_json', '~> 1.15', '>= 1.10.0'
  spec.add_runtime_dependency 'mini_portile2', '~> 2.8', '>= 2.8.1'

  spec.add_development_dependency 'rake', '~> 0.9.6'
  spec.add_development_dependency 'rake-compiler', '~> 0.9.9'
  spec.add_development_dependency 'rspec', '~> 3.9.0'
  spec.add_development_dependency 'rubocop', '~> 0.93.1'
end
