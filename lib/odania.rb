require 'odania/version'
require 'diplomat'
require 'erubis'
require 'fileutils'
require 'uri/http'
require 'public_suffix'
require 'deep_merge'
require 'json'
require 'socket'
require 'logger'

BASE_DIR = File.absolute_path File.join File.dirname(__FILE__), '..'
ENVIRONMENT = ENV['ENVIRONMENT'].nil? ? 'development' : ENV['ENVIRONMENT']
LOCAL_TEST_MODE = 'development'.eql?(ENVIRONMENT) unless defined? LOCAL_TEST_MODE
$logger = Logger.new(STDOUT)

module Odania
	CORE_PLUGIN_NAME = 'odania-core'

	autoload :Config, 'odania/config'
	autoload :Consul, 'odania/consul'
	autoload :Plugin, 'odania/plugin'
	autoload :Varnish, 'odania/varnish'

	def self.plugin
		Odania.configure
		@plugin = Plugin.new(@consul) if @plugin.nil?
		@plugin
	end

	def self.varnish
		@varnish = Varnish.new if @varnish.nil?
		@varnish
	end

	def self.configure(consul_url=nil)
		@consul = Consul.new(consul_url) if @consul.nil?
		$debug = false
	end

	def self.ips
		ips = []
		Socket.ip_address_list.each do |address|
			ip = address.ip_address
			ips << ip unless %w(127.0.0.1 ::1).include? ip
		end
		ips
	end

	# Rancher assigns two ip's the ip starting with 10. is routed through the hosts
	def self.primary_ip(ips)
		ips.each do |ip|
			return ip if ip.start_with? '10.'
		end

		ips.first
	end

	def self.varnish_sanitize(name)
		raise 'Could not sanitize varnish name!!' if name.nil?
		name.gsub(/[^0-9a-zA-Z_]/, '_')
	end
end
