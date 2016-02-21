# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'odania/version'

Gem::Specification.new do |spec|
	spec.name = 'odania'
	spec.version = Odania::VERSION
	spec.authors = ['Mike Petersen']
	spec.email = ['mike@odania-it.de']
	spec.summary = %q{Helper for the odania portal}
	spec.description = %q{Helper for the odania portal}
	spec.homepage = 'http://www.odania.com'
	spec.license = 'MIT'

	spec.files = `git ls-files -z`.split("\x0")
	spec.executables = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ['lib']

	spec.add_development_dependency 'bundler', '~> 1.5'
	spec.add_development_dependency 'rake'
	spec.add_development_dependency 'rspec'
	spec.add_development_dependency 'cucumber'
	spec.add_development_dependency 'guard'
	spec.add_development_dependency 'guard-rspec'
	spec.add_development_dependency 'codeclimate-test-reporter'

	spec.add_dependency 'diplomat'
	spec.add_dependency 'erubis'
	spec.add_dependency 'public_suffix'
	spec.add_dependency 'deep_merge'
end
