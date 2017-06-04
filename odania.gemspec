$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'odania/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
	s.name = 'odania'
	s.version = Odania::VERSION
	s.authors = ['Mike Petersen']
	s.email = ['mike@odania-it.de']
	s.homepage = 'https://www.odania.com'
	s.summary = 'Base for a Odania Web Application'
	s.description = 'Odania Base Helper'
	s.license = 'MIT'

	s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

	s.add_dependency 'rails', '~> 5.1.1'
	s.add_dependency 'mongoid'
	s.add_dependency 'simple_enum', '~> 2.3.0'
	s.add_dependency 'elasticsearch'
	s.add_dependency 'http_accept_language'
	s.add_dependency 'rack-cors'

	s.add_development_dependency 'sqlite3'
	s.add_development_dependency 'guard'
	s.add_development_dependency 'guard-test'
	s.add_development_dependency 'factory_girl'
end
