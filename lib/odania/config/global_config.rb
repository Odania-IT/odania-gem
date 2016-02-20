module Odania
	module Config
		class GlobalConfig < PluginConfig
			# Load the global configuration
			def load_global_config(config)
				throw 'Invalid global config!' if config.nil?

				reset
				@default_backend_groups = config['default_backend_groups'] unless config['default_backend_groups'].nil?

				unless config['domains'].nil?
					config['domains'].each_pair do |name, data|
						@domains[name].load(data)
					end
				end

				# load backends from consul
				Odania.plugin.get_all.each_pair do |name, instances|
					instances.each do |instance|
						add_backend(instance)
					end
				end

				#puts config.inspect
				#puts @backend_groups.inspect
				#puts @default_backend_groups.inspect

				self
			end

			def load_from_consul
				Odania.plugin.get_all.each_pair do |plugin_name, instances|
					puts "PLUGIN NAME #{plugin_name} - #{instances.count}" if $debug
					instances.each do |instance|
						add_backend(instance)
					end

					config = Odania.plugin.config_for plugin_name
					next if config.nil?

					begin
						puts JSON.pretty_generate config if $debug
						self.add_plugin_config(config)
					rescue => e
						puts 'Error loading configuration'
						puts 'Config start ' + '+' * 50
						puts JSON.pretty_generate config
						puts 'Config end ' + '+' * 50
						puts 'Error start ' + '+' * 50
						puts e.inspect
						puts 'Error end ' + '+' * 50
					end
				end
			end

			def generate_global_config
				puts 'Loading plugin configs from consul'
				load_from_consul

				puts 'Generating global config'
				config = self.dump
				puts JSON.pretty_generate config if $debug
				Odania.plugin.set_global_config config
				config
			end

			# Add the configuration from the plugin
			def add_plugin_config(plugin_cfg)
				config_section = plugin_cfg['config']
				group_name = plugin_cfg['plugin-config']['name']

				if $debug
					puts 'Loading configuration'
					puts JSON.pretty_generate plugin_cfg
				end

				@plugin_config[group_name] = plugin_cfg['plugin-config']
				@default_subdomains.deep_merge(plugin_cfg['default_subdomains']) unless plugin_cfg['default_subdomains'].nil?

				# Add this service as a default backend if specified
				@default_backend_groups << group_name if config_section['default']

				# Add config
				config_section.each_pair do |key, val|
					unless @config[key].nil?
						@duplicates.add :config, {key => 'already defined'}, group_name
					end
				end
				@config.deep_merge! config_section

				# Add Domain Information
				unless plugin_cfg['domains'].nil?
					plugin_cfg['domains'].each_pair do |name, data|
						@domains[name].add(data, group_name).each do |duplicate_key, duplicate_data|
							@duplicates.add duplicate_key, duplicate_data, group_name
						end
					end
				end

				true
			end

			def add_backend(backend_config)
				return if backend_config.ServiceAddress.nil? or backend_config.ServiceAddress.empty?

				backend = Backend.new(backend_config.ServiceName, backend_config.ServiceID, backend_config.ServiceAddress, backend_config.ServicePort)
				@backend_groups[backend_config.ServiceName].add_backend backend
				@backend_groups[backend_config.ServiceName].check_core_backend backend_config.ServiceTags
			end

			def reset
				super

				@default_backend_groups = []
				@duplicates = Duplicates.new
				@backend_groups = Hash.new { |hash, key| hash[key] = BackendGroup.new(key) }
				@default_subdomains = {}

				@domains['_general'].add_subdomain('_general')
			end

			def duplicates
				@duplicates.duplicates
			end

			def backend_groups
				@backend_groups
			end

			def default_backend
				group_name = @default_backend_groups.first
				group_name = @backend_groups.keys.first if group_name.nil?
				raise 'No backend found' if @backend_groups.empty?
				@backend_groups[group_name].backends.first
			end

			def default_subdomains
				@default_subdomains
			end

			def default_redirects
				general = @domains['_general'].subdomain('_general')
				return {} if general.nil?
				general.redirects
			end

			def dump
				cfg = super
				cfg['default_backend_groups'] = @default_backend_groups
				cfg
			end
		end
	end
end
