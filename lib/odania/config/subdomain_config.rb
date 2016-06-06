module Odania
	module Config
		class SubdomainConfig

			def initialize(global_config, domain, subdomain)
				@global_config = global_config
				@domain = domain
				@subdomain = subdomain
			end

			def generate
				@layout = get_layout_name
				config = {
					layout: @layout,
					config: generate_merged_config,
					partials: generate_merged_partials
				}

				layout_config = get_layout_config @layout
				layout_config.delete('assets')
				config[:styles] = layout_config['config']['styles']

				if $debug
					$logger.debug 'Generated config:'
					$logger.debug JSON.pretty_generate(config)
				end

				config
			end

			private

			def get_layout_name
				# subdomain specific layouts
				result = retrieve_hash_path @global_config, ['domains', @domain, @subdomain, 'config', 'layout']
				return result unless result.nil?

				# domain specific layouts
				result = retrieve_hash_path @global_config, ['domains', @domain, '_general', 'config', 'layout']
				return result unless result.nil?

				# general layouts
				result = retrieve_hash_path @global_config, %w(domains _general _general config layout)
				return result unless result.nil?

				# general layouts
				result = retrieve_hash_path @global_config, %w(config layout)
				return result unless result.nil?

				'simple'
			end

			def get_layout_config(layout)
				# subdomain specific layouts
				result = retrieve_hash_path @global_config, ['domains', @domain, @subdomain, 'layouts', layout]
				return result unless result.nil?

				# domain specific layouts
				result = retrieve_hash_path @global_config, ['domains', @domain, '_general', 'layouts', layout]
				return result unless result.nil?

				# general layouts
				result = retrieve_hash_path @global_config, ['domains', '_general', '_general', 'layouts', layout]
				return result unless result.nil?

				{}
			end

			def generate_merged_config
				config = retrieve_hash_path @global_config, %w(domains _general _general config)
				config = {} if config.nil?

				# domain specific layouts
				result = retrieve_hash_path @global_config, ['domains', @domain, '_general', 'config']
				config.deep_merge!(result) unless result.nil?

				# subdomain specific layouts
				result = retrieve_hash_path @global_config, ['domains', @domain, @subdomain, 'config']
				config.deep_merge!(result) unless result.nil?

				config
			end

			def generate_merged_partials
				partials = retrieve_hash_path @global_config, %w(partials _general _general default)
				partials = {} if partials.nil?

				# general specific layout
				result = retrieve_hash_path @global_config, ['partials', '_general', '_general', 'layouts', @layout]
				partials.deep_merge!(result) unless result.nil?

				# domain specific
				result = retrieve_hash_path @global_config, ['partials', @domain, '_general', 'default']
				partials.deep_merge!(result) unless result.nil?

				# domain specific layout
				result = retrieve_hash_path @global_config, ['partials', @domain, '_general', 'layouts', @layout]
				partials.deep_merge!(result) unless result.nil?

				# subdomain
				result = retrieve_hash_path @global_config, ['partials', @domain, @subdomain, 'default']
				partials.deep_merge!(result) unless result.nil?

				# subdomain specific layout
				result = retrieve_hash_path @global_config, ['partials', @domain, @subdomain, 'layouts', @layout]
				partials.deep_merge!(result) unless result.nil?

				partials
			end

			def retrieve_hash_path(hash, path)
				key = path.shift

				return nil until hash.has_key? key
				return hash[key] if path.empty?
				retrieve_hash_path hash[key], path
			end

		end
	end
end
