module Odania
	class Consul
		attr_reader :service, :config, :event, :health

		def initialize(consul_url)
			consul_url = ENV['CONSUL_ADDR'] if consul_url.nil?
			consul_url = 'http://consul:8500' if consul_url.nil?
			$logger.info "Consul URL: #{consul_url}" if $debug
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
				Diplomat::Service.get_all.each_pair do |key, _value|
					services[key.to_s] = get_all_for(key)
				end
				$logger.info "SERVICES: #{JSON.pretty_generate services}" if $debug
				services
			end

			def get_all_for(plugin_name)
				begin
					instances = get(plugin_name, :all)
				rescue
					instances = []
				end
				instances.is_a?(Array) ? instances : [instances]
			end

			# TODO Is there an easier way to get the first service tagges with "core-backend"?
			def get_core_service
				core_backends = []
				begin
					Diplomat::Service.get_all.each_pair do |key, tags|
						core_backends << key if tags.include? 'core-backend'
					end
				rescue
					$logger.warn 'No services in consul!'
				end

				get(core_backends.shuffle.first)
			end

			def get(key, scope=:first)
				Diplomat::Service.get(key, scope)
			end

			def register(consul_config)
				if Diplomat::Service.register consul_config
					$logger.info 'Service registered' if $debug
				else
					$logger.error 'Error registering service'
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
