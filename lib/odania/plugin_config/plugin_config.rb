# Generate a joined configuration for all available plugins

require_relative 'models/backend'
require_relative 'models/backend_group'
require_relative 'models/domain'
require_relative 'models/layout'
require_relative 'models/page'
require_relative 'models/redirect'
require_relative 'models/sub_domain'

module Odania
	module PluginConfig
		class Base
			def initialize
				@default_backend_groups = []
				@backend_groups = Hash.new { |hash, key| hash[key] = BackendGroup.new(key) }
				@redirects = Hash.new { |hash, key| hash[key] = Redirect.new(key) }
				@domains = Hash.new { |hash, key| hash[key] = Domain.new(key) }
				@default_subdomains = {}
				@layouts = Hash.new { |hash, key| hash[key] = Layout.new }

				@duplicates = Duplicates.new
			end

			def load_from_consul
				Odania.plugin.get_all.each_pair do |plugin_name, instances|
					puts "PLUGIN NAME #{plugin_name} - #{instances.count}" if $debug
					instances.each do |instance|
						add_backend(instance)
					end

					config = Odania.plugin.config_for plugin_name
					next if config.nil?

					puts JSON.pretty_generate config if $debug
					self.load(config)
				end
			end

			def load_global_config(config)
				throw 'Invalid global config!' if config.nil?

				reset
				@default_backend_groups = config['default_backend_groups'] unless config['default_backend_groups'].nil?
				@default_subdomains = config['default_subdomains'] unless config['default_subdomains'].nil?

				unless config['backends'].nil?
					config['backends'].each_pair do |group_name, group|
						group['backends'].each do |data|
							backend = Backend.new(data['service_name'], data['instance_name'], data['host'], data['port'])
							@backend_groups[group_name].add_backend backend
						end
					end
				end

				unless config['redirects'].nil?
					config['redirects'].each_pair do |src, target|
						@redirects[src].target = target
					end
				end

				unless config['domains'].nil?
					config['domains'].each_pair do |name, data|
						@domains[name].load(data)
					end
				end

				unless config['layouts'].nil?
					config['layouts'].each_pair do |name, data|
						@layouts[name].load(data)
					end
				end

				self
			end

			def add_backend(backend_config)
				return if backend_config.ServiceAddress.nil? or backend_config.ServiceAddress.empty?

				backend = Backend.new(backend_config.ServiceName, backend_config.ServiceID, backend_config.ServiceAddress, backend_config.ServicePort)
				@backend_groups[backend_config.ServiceName].add_backend backend
			end

			def load(config)
				group_name = config['name']

				if $debug
					puts 'Loading configuration'
					puts JSON.pretty_generate config
				end

				# Add this service as a default backend if specified
				@default_backend_groups << group_name if config['default']

				# Add redirect info
				unless config['redirects'].nil?
					config['redirects'].each_pair do |idx, val|
						@duplicates.add(group_name, :redirect, idx, @redirects[idx].plugins) unless @redirects[idx].add(val, group_name)
					end
				end

				# Add Domain Information
				unless config['domains'].nil?
					config['domains'].each_pair do |domain_name, domain_data|
						uri = URI.parse("http://#{domain_name}")
						domain = PublicSuffix.parse(uri.host)
						base_domain = domain.domain
						subdomain_name = domain.trd

						# Add subdomain with config
						subdomain = @domains[base_domain].add_subdomain(subdomain_name)
						errors = subdomain.set_config(domain_data['config'], group_name)
						errors.each do |error|
							@duplicates.add(group_name, error[:type], error[:key], error[:plugins])
						end

						unless domain_data['public_pages'].nil?
							domain_data['public_pages'].each_pair do |language, language_contents|
								language_contents.each_pair do |web_url, plugin_url|
									unless subdomain.add_page(web_url, group_name, plugin_url, group_name)
										@duplicates.add(group_name, :page, web_url, subdomain.plugins(:page, web_url))
									end
								end
							end
						end

						domain_data['assets'].each_pair do |web_url, plugin_url|
							unless subdomain.add_asset(web_url, group_name, plugin_url, group_name)
								@duplicates.add(group_name, :asset, web_url, subdomain.plugins(:asset, web_url))
							end
						end
					end
				end

				unless config['layouts'].nil?
					config['layouts'].each_pair do |name, layout_config|
						unless @layouts[name].set_config(layout_config, group_name)
							@duplicates.add(group_name, :layout, name, @layouts[name].plugins)
						end
					end
				end

				@default_subdomains = config['default_subdomains'] unless config['default_subdomains'].nil?
			end

			def generate
				if $debug
					puts 'Default Backend Groups ----------------------------------'
					puts JSON.pretty_generate @default_backend_groups
					puts 'Backend Groups ----------------------------------'
					puts JSON.pretty_generate @backend_groups
					puts 'Redirects ----------------------------------'
					puts JSON.pretty_generate @redirects
					puts 'Domains ----------------------------------'
					puts JSON.pretty_generate @domains
					puts 'Default SubDomains ----------------------------------'
					puts JSON.pretty_generate @default_subdomains
					puts 'Generate ----------------------------------'
				end
				config = {
					'default_backend_groups' => @default_backend_groups,
					'default_subdomains' => @default_subdomains,
					'backends' => {},
					'redirects' => {},
					'domains' => {},
					'layouts' => {}
				}

				@backend_groups.each_pair do |group_name, instance|
					config['backends'][group_name] = instance.dump
				end

				@redirects.each_pair do |src, redirect|
					config['redirects'][src] = redirect.target
				end

				@domains.each_pair do |domain_name, domain|
					config['domains'][domain_name] = domain.dump
				end

				@layouts.each_pair do |name, layout|
					config['layouts'][name] = layout.dump
				end

				puts JSON.pretty_generate config if $debug
				Odania.plugin.set_global_config config
			end

			def backend_groups
				@backend_groups
			end

			def default_backend
				group_name = @default_backend_groups.first
				group_name = @backend_groups.keys.first if group_name.nil?

				@backend_groups[group_name].backends.first
			end

			def redirects
				@redirects
			end

			def domains
				@domains
			end

			def default_subdomains
				@default_subdomains
			end

			private

			def reset
				@default_backend_groups = []
				@backend_groups = Hash.new { |hash, key| hash[key] = BackendGroup.new(key) }
				@redirects = Hash.new { |hash, key| hash[key] = Redirect.new(key) }
				@domains = Hash.new { |hash, key| hash[key] = Domain.new(key) }
				@default_subdomains = {}
				@layouts = Hash.new { |hash, key| hash[key] = Layout.new }

				@duplicates = Duplicates.new
			end
		end

		class Duplicates
			def initialize
				@duplicates = Hash.new { |hash, key| hash[key] = Hash.new { |hash, key| hash[key] = Duplicate.new } }
			end

			def add(group, type, key, plugin_info)
				@duplicates[group][type].add(key, plugin_info)
			end

			class Duplicate
				def initialize
					@duplicate = {}
				end

				def add(key, plugin_info)
					@duplicate[key] = [] if @duplicate[key].nil?
					@duplicate[key] += plugin_info
				end
			end
		end
	end
end
