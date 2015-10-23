module Odania
	class Service < Odania::Consul
		def register_service(plugin_name, plugin_instance_name, ip)
			puts "Registering service #{plugin_name} as instance #{plugin_instance_name}"
			if Diplomat::Service.register consul_service_config(plugin_name, plugin_instance_name, ip)
				puts 'Service registered'
			else
				puts 'Error registering service'
			end
		end

		private

		def consul_service_config(plugin_name, plugin_instance_name, ip)
			{
				'id' => plugin_instance_name,
				'name' => plugin_name,
				'tags' => ['odania-static'],
				'port' => 80,
				'token' => plugin_instance_name,
				'checks' => [
					{
						'id' => plugin_name,
						'name' => 'HTTP on port 80',
						'http' => "http://#{ip}:80/health",
						'interval' => '10s',
						'timeout' => '1s'
					}
				]
			}
		end
	end
end
