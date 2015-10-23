require 'odania/version'
require 'diplomat'

module Odania
	autoload :Consul, 'odania/consul'
	autoload :Service, 'odania/service'
	autoload :Plugin, 'odania/plugin'

	def self.service(consul_url=nil)
		if @service.nil?
			Odania.configure
			@service = Service.new(consul_url)
		end
		@service
	end

	def self.plugin
		Odania.configure
		@plugin = Plugin.new if @plugin.nil?
		@plugin
	end

	def self.configure(consul_url=nil)
		if @configured.nil?
			consul_url = "http://#{ENV['CONSUL_PORT_8500_TCP_ADDR']}:#{ENV['CONSUL_PORT_8500_TCP_PORT']}" if consul_url.nil?
			puts "Consul URL: #{consul_url}"
			Diplomat.configure do |config|
				# Set up a custom Consul URL
				config.url = consul_url
			end
			@configured = true
		end
	end
end
