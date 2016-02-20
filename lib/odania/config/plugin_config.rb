module Odania
	module Config
		class PluginConfig
			attr_accessor :domains, :config, :default_subdomains, :plugin_config

			def initialize
				reset
			end

			# Load the global configuration
			def load(data)
				reset
				@config = data['config'] unless data['config'].nil?
				@plugin_config = data['plugin-config'] unless data['plugin-config'].nil?
				@default_subdomains = data['default_subdomains'] unless data['default_subdomains'].nil?
				unless data['domains'].nil?
					data['domains'].each_pair do |name, data|
						@domains[name].load(data)
					end
				end

				true
			end

			def [](key)
				@domains[key]
			end

			# Reset configuration
			def reset
				@config = {}
				@plugin_config = {}
				@domains = Hash.new { |hash, key| hash[key] = Domain.new(key) }
			end

			def dump
				domain_data = {}
				@domains.each_pair do |name, domain|
					domain_data[name] = domain.dump
				end

				{
					'plugin-config' => plugin_config,
					'config' => config,
					'default_subdomains' => @default_subdomains,
					'domains' => domain_data
				}
			end
		end
	end
end
