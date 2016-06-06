module Odania
	module Config
		class PluginConfig
			attr_accessor :domains, :config, :valid_domains, :default_domains, :plugin_config, :partials

			def initialize
				reset
			end

			# Load the global configuration
			def load(data)
				reset
				@config = data['config'] unless data['config'].nil?
				@plugin_config = data['plugin-config'] unless data['plugin-config'].nil?
				@valid_domains = data['valid_domains'] unless data['valid_domains'].nil?
				@default_domains = data['default_domains'] unless data['default_domains'].nil?
				@partials = data['partials'] unless data['partials'].nil?
				unless data['domains'].nil?
					data['domains'].each_pair do |name, domain_data|
						@domains[name].load(domain_data)
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
				@default_domains = {}
				@valid_domains = {}
				@partials = {}
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
					'default_domains' => @default_domains,
					'valid_domains' => @valid_domains,
					'partials' => @partials,
					'domains' => domain_data
				}
			end
		end
	end
end
