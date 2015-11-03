module Odania
	class Consul
		attr_accessor :service, :config, :event, :health

		def initialize(consul_url)
			consul_url = "http://#{ENV['CONSUL_PORT_8500_TCP_ADDR']}:#{ENV['CONSUL_PORT_8500_TCP_PORT']}" if consul_url.nil?
			puts "Consul URL: #{consul_url}" if $debug
			Diplomat.configure do |config|
				# Set up a custom Consul URL
				config.url = consul_url
			end

			@service = Service.new
			@config = Config.new
			@event = Event.new
			@health = Health.new
		end

		class Config
			def get(path)
				begin
					JSON.parse Diplomat::Kv.get path
				rescue Diplomat::KeyNotFound
					nil
				end
			end

			def get_all(path)
				retrieve_value path
			end

			def set(key, value)
				Diplomat::Kv.put(key, JSON.dump(value))
			end

			def delete(key)
				Diplomat::Kv.delete(key)
			end

			protected

			def retrieve_value(plugin_path)
				begin
					result = {}
					Diplomat::Kv.get(plugin_path, :recurse => true).each do |data|
						result[data[:key]] = JSON.parse data[:value]
					end
					result
				rescue Diplomat::KeyNotFound
					{}
				end
			end
		end

		class Service
			def get_all
				services = {}
				Diplomat::Service.get_all.each_pair do |key, value|
					services[key.to_s] = get_all_for(key)
				end
				puts "SERVICES: #{JSON.pretty_generate services}" if $debug
				services
			end

			def get_all_for(plugin_name)
				instances = get(plugin_name, :all)
				instances.is_a?(Array) ? instances : [instances]
			end

			def get(key, scope=:first)
				Diplomat::Service.get(key, scope)
			end

			def register(consul_config)
				if Diplomat::Service.register consul_config
					puts 'Service registered' if $debug
				else
					puts 'Error registering service' if $debug
				end
			end

			def deregister(name)
				Diplomat::Service.deregister name
			end

			def build_config(plugin_name, plugin_instance_name, ip, tags=[], port=80)
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

		class Event
			def fire(key, value)
				Diplomat::Event.fire key, value
			end
		end

		class Health
			def state(state=:any)
				Diplomat::Health.state(state)
			end

			def service(name)
				Diplomat::Health.service(name)
			end
		end
	end
end
