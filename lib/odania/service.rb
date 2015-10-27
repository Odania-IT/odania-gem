module Odania
	class Service < Odania::Consul
		def register_service(consul_config)
			if Diplomat::Service.register consul_config
				puts 'Service registered'
			else
				puts 'Error registering service'
			end
		end

		def get(name, scope=:first)
			begin
				Diplomat::Service.get(name, scope)
			rescue Diplomat::PathNotFound => e
				puts "Service not found: #{e}"
				puts e.backtrace.inspect

				throw e
			end
		end

		def get_all
			Diplomat::Service.get_all
		end

		def consul_service_config(plugin_name, plugin_instance_name, ip, tags=[], port=80)
			{
				'id' => plugin_instance_name,
				'name' => plugin_name,
				'tags' => tags,
				'address' => ip,
				'port' => port,
				'token' => plugin_instance_name,
				'checks' => [
					{
						'id' => plugin_name,
						'name' => "HTTP on port #{port}",
						'http' => "http://#{ip}:#{port}/health",
						'interval' => '10s',
						'timeout' => '1s'
					}
				]
			}
		end
	end
end
