module Odania
	module PluginConfig
		class Backend
			attr_accessor :service_name, :instance_name, :host, :port

			def initialize(service_name, instance_name, host, port)
				self.service_name = service_name
				self.instance_name = instance_name
				self.host = host
				self.port = port
			end

			def dump
				{
					'service_name' => service_name,
					'instance_name' => instance_name,
					'host' => host,
					'port' => port
				}
			end

			def load(data)
				self.service_name = data['service_name']
				self.instance_name = data['instance_name']
				self.host = data['host']
				self.port = data['port']
				self
			end
		end
	end
end
