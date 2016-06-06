module Odania
	class Plugin
		INSTANCE_FILES_PATH = '/tmp/plugin_instance_name_'

		def initialize(consul)
			@consul = consul
			@plugin_config = Config::GlobalConfig.new
		end

		def register(plugin_instance_name, plugin_config)
			plugin_name = plugin_config['plugin-config']['name']

			# Write configuration of the plugin
			@consul.config.set(get_plugin_config_path_for(plugin_name), plugin_config)

			# Register service
			consul_config = @consul.service.build_config(plugin_name, plugin_instance_name, plugin_config['plugin-config']['ip'], plugin_config['plugin-config']['tags'], plugin_config['plugin-config']['port'])
			@consul.service.register(consul_config)

			# Fire event
			@consul.event.fire 'service-registered', "#{plugin_name}|#{plugin_instance_name}"
			"#{plugin_name}|#{plugin_instance_name}"
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
			"#{plugin_name}_#{Socket.gethostname.gsub(/[^0-9a-zA-Z_]/, '_')}"
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

		def set_subdomain_config(full_domain, config)
			@consul.config.set get_subdomain_config_path(full_domain), config
		end

		def get_subdomain_config(full_domain)
			@consul.config.get get_subdomain_config_path(full_domain)
		end

		def set_valid_domain_config(config)
			@consul.config.set get_valid_domain_config_path, config
		end

		def get_valid_domain_config
			@consul.config.get get_valid_domain_config_path
		end

		def get_domain_config_for(domain, global_config=nil)
			global_config = get_global_config if global_config.nil?

			return global_config['domains'][domain], domain unless global_config['domains'][domain].nil?
			return false, nil
		end

		def health
			@consul.health
		end

		private

		def get_subdomain_config_path(full_domain)
			"subdomain_config/#{full_domain}"
		end

		def get_valid_domain_config_path
			'valid_domain_config'
		end

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
