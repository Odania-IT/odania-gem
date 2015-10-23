module Odania
	class Consul
		def initialize
			consul_url = "http://#{ENV['CONSUL_PORT_8500_TCP_ADDR']}:#{ENV['CONSUL_PORT_8500_TCP_PORT']}"
			puts "Consul: #{consul_url}"

			Diplomat.configure do |config|
				# Set up a custom Consul URL
				config.url = consul_url
			end
		end

		def get_config
			configs = retrieve_value 'plugins'
			puts
			puts 'Configs'
			puts configs.inspect
			puts
			puts

			result = {}
			configs.each do |json_data|
				config = JSON.parse json_data[:value]
				# TODO merge
				puts config.inspect
				result = config
			end
			result
		end

		private

		def retrieve_value(plugin_path)
			begin
				Diplomat::Kv.get(plugin_path, :recurse => true)
			rescue Diplomat::KeyNotFound
				[]
			end
		end
	end
end
