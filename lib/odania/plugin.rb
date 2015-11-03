require_relative 'plugin_config/plugin_config'

module Odania
	class Plugin
		INSTANCE_FILES_PATH = '/tmp/plugin_instance_name_'

		def initialize(consul)
			@consul = consul
			@plugin_config = PluginConfig::Base.new
		end

		def register(plugin_instance_name, plugin_config)
			plugin_name = plugin_config['name']

			# Write configuration of the plugin
			@consul.config.set(get_plugin_config_path_for(plugin_name), plugin_config)

			# Register service
			consul_config = @consul.service.build_config(plugin_name, plugin_instance_name, plugin_config['ip'], plugin_config['tags'], plugin_config['port'])
			@consul.service.register(consul_config)

			# Fire event
			@consul.event.fire 'service-registered', "#{plugin_name}|#{plugin_instance_name}"
		end

		def deregister(plugin_instance_name)
			@consul.service.deregister(plugin_instance_name)
		end

		def get_all
			@consul.service.get_all
		end

		def config_for(plugin_name)
			@consul.config.get get_plugin_config_path_for(plugin_name)
		end

		# Generate a unique number for this instance of the plugin
		def get_plugin_instance_name(plugin_name)
			plugin_instance_name_file = "#{INSTANCE_FILES_PATH}#{plugin_name}"

			plugin_instance_name = nil
			plugin_instance_name = File.read plugin_instance_name_file if File.exists? plugin_instance_name_file
			return plugin_instance_name unless plugin_instance_name.nil?

			available_instances = @consul.service.get_all_for plugin_name
			plugin_instance_name = "#{plugin_name}_#{available_instances.length + 1}"
			File.write plugin_instance_name_file, plugin_instance_name
			plugin_instance_name
		end

		def plugin_config
			@plugin_config
		end

		def set_global_config(config)
			@consul.config.set get_global_plugin_config_path, config
		end

		def get_global_config
			@consul.config.get get_global_plugin_config_path
		end

		def health
			@consul.health
		end

		private

		def get_global_plugin_config_path
			'global_plugins_config'
		end

		def get_plugin_config_path
			'plugins_config'
		end

		def get_plugin_config_path_for(plugin_name)
			"#{get_plugin_config_path}/#{plugin_name}"
		end
	end
end
