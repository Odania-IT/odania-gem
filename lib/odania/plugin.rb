module Odania
	class Plugin < Odania::Consul
		def plugins_config
			configs = retrieve_value 'plugins'

			result = []
			configs.each do |json_data|
				begin
					result << JSON.parse(json_data[:value])
				rescue => e
					puts "Can not parse config: #{e} \n\n #{json_data.inspect}"
				end
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
			puts 'Detecting plugin instance name'
			plugin_instance_name_file = '/tmp/plugin_instance_name'

			plugin_instance_name = nil
			plugin_instance_name = File.read plugin_instance_name_file if File.exists? plugin_instance_name_file
			return plugin_instance_name unless plugin_instance_name.nil?

			available_plugins = retrieve_value(get_plugin_path(plugin_name))
			puts 'Current plugins'
			puts available_plugins.inspect

			plugin_instance_name = "#{plugin_name}_#{available_plugins.length + 1}"
			File.write plugin_instance_name_file, plugin_instance_name
			plugin_instance_name
		end
	end
end
