module Odania
	class Plugin < Odania::Consul
		def plugins_config
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

		def add_plugin(plugin_config)
			plugin_name = plugin_config['name']
			plugin_instance_name = get_plugin_instance_name plugin_name

			puts "Writing plugin instance config: #{plugin_instance_name}"
			Diplomat::Kv.put("#{get_plugin_path(plugin_name)}#{plugin_instance_name}", JSON.dump(plugin_config))

			consul_config = Odania.service.consul_service_config(plugin_name, plugin_instance_name, plugin_config['ip'], plugin_config['tags'], plugin_config['port'])
			Odania.service.register_service(consul_config)

			Diplomat::Event.fire('updated_plugin_config', "#{plugin_name}|#{plugin_instance_name}")
		end

		private

		def get_plugin_path(plugin_name)
			"plugins/#{plugin_name}/"
		end

		# Generate a unique number for this instance of the plugin
		def get_plugin_instance_name(plugin_name)
			available_plugins = retrieve_value(get_plugin_path(plugin_name))

			puts 'Current plugins'
			puts available_plugins.inspect

			"#{plugin_name}_#{available_plugins.length + 1}"
		end
	end
end
