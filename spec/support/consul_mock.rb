class ConsulMock < Odania::Consul
	attr_reader :service, :config, :event, :health
	attr_accessor :configuration

	def initialize
		self.configuration = {
			'global_plugins_config' => {
				'domains' => {}
			}
		}

		@service = Service.new
		@config = Config.new(self.configuration)
		@event = Event.new
		@health = Health.new
	end

	class Config
		def initialize(configuration)
			@configuration = configuration
		end

		def get(path)
			@configuration[path]
		end

		def get_all(path)
			result = {}
			@configuration.each_pair do |key, value|
				result[key] = value if key.start_with? path
			end

			result
		end

		def set(key, value)
			@configuration[key] = value
		end

		def delete(key)
			@configuration.delete[key]
		end
	end

	class Service
		attr_accessor :services

		def initialize
			@services = {}
		end

		def get_all
			@services
		end

		def get_all_for(plugin_name)
			result = []
			@services.each_pair do |key, val|
				result << val if key.start_with? plugin_name
			end
			result
		end

		def get(key, scope=:first)
			@services[key]
		end

		def register(consul_config)
			@services[consul_config['id']] = consul_config
		end

		def deregister(name)
			@services.delete name
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
		def initialize
			@events = Hash.new { |hash, key| hash[key] = [] }
		end

		def fire(key, value)
			@events[key] << value
		end
	end

	class Health
		def initialize
			@health_states = [
				{'Node' => '04977bad2036', 'CheckID' => 'serfHealth', 'Name' => 'Serf Health Status', 'Status' => 'passing', 'Notes' => '', 'Output' => 'Agent alive and reachable', 'ServiceID' => '', 'ServiceName' => ''},
				{'Node' => '04977bad2036', 'CheckID' => 'service_1', 'Name' => "Service 'static-content' check", 'Status' => 'passing', 'Notes' => '', 'Output' => 'HTTP GET http://172.17.0.4:80/health: 200 OK Output: OK', 'ServiceID' => 'static_content_1', 'ServiceName' => 'static-content'}
			]
		end

		def state(state=:any)
			@health_states
		end

		def service(name)
			Diplomat::Health.service(name)
		end
	end
end
