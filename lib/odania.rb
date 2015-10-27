require 'odania/version'
require 'diplomat'

module Odania
	CORE_PLUGIN_NAME = 'odania-core'
	INTERNAL_VARNISH_NAME = 'odania-varnish-internal'

	autoload :Consul, 'odania/consul'
	autoload :Service, 'odania/service'
	autoload :Plugin, 'odania/plugin'

	def self.service
		if @service.nil?
			Odania.configure
			@service = Service.new
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

	def self.ips
		ips = []
		Socket.ip_address_list.each do |address|
			ip = address.ip_address
			ips << ip unless %w(127.0.0.1 ::1).include? ip
		end
		ips
	end

	def self.varnish_sanitize(name)
		name.gsub(/[^0-9a-zA-Z_]/, '_')
	end
end
