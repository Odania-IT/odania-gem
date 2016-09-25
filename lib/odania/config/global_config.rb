module Odania
	module Config
		class GlobalConfig < PluginConfig
			# Load the global configuration
			def load_global_config(config)
				throw 'Invalid global config!' if config.nil?

				reset
				@default_backend_groups = config['default_backend_groups'] unless config['default_backend_groups'].nil?
				@valid_domains = config['valid_domains'] unless config['valid_domains'].nil?
				@default_domains = config['default_domains'] unless config['default_domains'].nil?
				@partials = config['partials'] unless config['partials'].nil?

				unless config['domains'].nil?
					config['domains'].each_pair do |name, data|
						@domains[name].load(data)
					end
				end

				# load backends from consul
				Odania.plugin.get_all.each_pair do |_name, instances|
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
					$logger.info "PLUGIN NAME #{plugin_name} - #{instances.count}" if $debug
					instances.each do |instance|
						add_backend(instance)
					end

					config = Odania.plugin.config_for plugin_name
					next if config.nil?

					begin
						puts JSON.pretty_generate config if $debug
						self.add_plugin_config(config)
					rescue => e
						$logger.error 'Error loading configuration'
						$logger.error 'Config start ' + '+' * 50
						puts JSON.pretty_generate config
						$logger.error 'Config end ' + '+' * 50
						$logger.error 'Error start ' + '+' * 50
						$logger.error e.inspect
						$logger.error 'Error end ' + '+' * 50
						$logger.error 'Error backtrace start ' + '+' * 50
						e.backtrace.each do |line|
							$logger.error line
						end
						$logger.error 'Error backtrace end ' + '+' * 50
					end
				end
			end

			def generate_global_config
				$logger.info 'Loading plugin configs from consul'
				begin
					load_from_consul
				rescue
					$logger.warn 'No current configuration'
				end

				$logger.info 'Generating global config'
				config = self.dump
				puts JSON.pretty_generate config if $debug
				Odania.plugin.set_global_config config

				generate_subdomain_configs config
				write_valid_domain_config

				config
			end

			# Generate a config per subdomain
			def generate_subdomain_configs(config)
				$logger.info 'Generating subdomain configs'
				@valid_domains.each do |domain, subdomains|
					subdomains.each do |subdomain|
						$logger.info "Generating Subdomain Config for Domain: #{domain} Subdomain: #{subdomain}"

						begin
							subdomain_config = SubdomainConfig.new(config, domain, subdomain).generate
							Odania.plugin.set_subdomain_config "#{subdomain}.#{domain}", subdomain_config
						rescue => e
							$logger.error "Error generating subdomain config: #{e}"
							$logger.error e.backtrace.join("\n")
						end
					end
				end
			end

			def write_valid_domain_config
				$logger.info 'Writing valid domain config'
				config = {
					valid_domains: @valid_domains,
					default_domains: @default_domains
				}
				Odania.plugin.set_valid_domain_config config
			end

			# Add the configuration from the plugin
			def add_plugin_config(plugin_cfg)
				config_section = plugin_cfg['config']
				group_name = plugin_cfg['plugin-config']['name']

				if $debug
					$logger.info 'Loading configuration'
					puts JSON.pretty_generate plugin_cfg
				end

				@plugin_config[group_name] = plugin_cfg['plugin-config']
				@valid_domains.deep_merge!(plugin_cfg['valid_domains']) unless plugin_cfg['valid_domains'].nil?
				@default_domains.deep_merge!(plugin_cfg['default_domains']) unless plugin_cfg['default_domains'].nil?
				@partials.deep_merge!(plugin_cfg['partials']) unless plugin_cfg['partials'].nil?

				# Add this service as a default backend if specified
				@default_backend_groups << group_name if plugin_cfg['plugin-config']['default']

				# Add config
				unless config_section.nil?
					config_section.each_pair do |key, _val|
						unless @config[key].nil?
							@duplicates.add :config, {key => 'already defined'}, group_name
						end
					end
					@config.deep_merge! config_section
				end

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
				@valid_domains = {}
				@default_domains = {}
				@partials = {}

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

			def valid_domains
				@valid_domains
			end

			def default_domains
				@default_domains
			end

			def partials
				@partials
			end

			def default_redirects
				general = @domains['_general'].subdomain('_general')
				return {} if general.nil?
				general.redirects
			end

			def dump
				cfg = super
				cfg['default_backend_groups'] = @default_backend_groups
				cfg['default_domains'] = @default_domains
				cfg['valid_domains'] = @valid_domains
				cfg['partials'] = @partials
				cfg
			end
		end
	end
end
