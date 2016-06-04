ENV['ENVIRONMENT'] = 'test'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'odania'
require_relative 'support/consul_mock'

require 'hashdiff'

RSpec.configure do |config|
	config.before(:each) do
		$consul_mock = ConsulMock.new

		allow(Odania).to receive(:plugin) do
			Odania::Plugin.new($consul_mock)
		end
	end
end
