module Odania
	module Config
		class SubDomain
			attr_accessor :name, :config, :direct, :dynamic, :internal, :from_plugin, :redirects

			def initialize(name)
				self.name = name
				reset
			end

			def set_config(config_data, group_name)
				errors = []
				return errors if config_data.nil?

				config_data.each_pair do |key, val|
					from_plugin[:config][key] << group_name
					errors << {:type => :config, :plugins => from_plugin[:config][key], :key => key} unless config[key].nil?
					config[key] = val
				end
				errors
			end

			def add_page(type, web_url, group_name, url_data, plugin_name)
				result = true
				result = false unless self.pages[type].key? web_url
				self.pages[type][web_url].group_name = group_name
				self.pages[type][web_url].plugin_url = url_data['plugin_url']
				self.pages[type][web_url].cacheable = url_data['cacheable'] unless url_data['cacheable'].nil?
				self.pages[type][web_url].expires = url_data['expires'] unless url_data['expires'].nil?
				@plugins[:page]["#{type}-#{web_url}"] << plugin_name
				result
			end

			def add_internal(web_url, group_name, plugin_url, plugin_name)
				result = true
				result = false unless self.assets.key? web_url
				self.assets[web_url].group_name = group_name
				self.assets[web_url].plugin_url = plugin_url
				@plugins[:asset][web_url] << plugin_name
				result
			end

			def get_redirects
				return {} if self.config.nil?
				return {} if self.config['redirects'].nil?
				self.config['redirects']
			end

			def plugins(type, key)
				@plugins[type][key]
			end

			def dump
				direct_data = {}
				direct.each_pair do |web_url, page|
					direct_data[web_url] = page.dump
				end

				dynamic_data = {}
				dynamic.each_pair do |web_url, page|
					dynamic_data[web_url] = page.dump
				end

				{
					'redirects' => self.redirects,
					'config' => self.config,
					'direct' => direct_data,
					'dynamic' => dynamic_data,
					'internal' => self.internal.dump
				}
			end

			def load(data)
				reset
				self.add(data)
			end

			def add(data, group_name=nil)
				self.config = data['config'] unless data['config'].nil?
				duplicates = Hash.new { |hash, key| hash[key] = [] }

				unless data['direct'].nil?
					data['direct'].each_pair do |name, data|
						duplicates[:direct] << name if self.direct.key? name
						self.direct[name].load(data, group_name)
					end
				end

				unless data['dynamic'].nil?
					data['dynamic'].each_pair do |name, data|
						duplicates[:dynamic] << name if self.direct.key? name
						self.dynamic[name].load(data, group_name)
					end
				end

				self.internal.load(data['internal']) unless data['internal'].nil?
				unless data['redirects'].nil?
					data['redirects'].each_pair do |src_url, target_url|
						duplicates[:redirect] << src_url if self.redirects.key? src_url
						self.redirects[src_url] = target_url
					end
				end

				duplicates
			end

			def [](type)
				return self.direct if 'direct'.eql? type.to_s
				self.dynamic
			end

			private

			def reset
				self.config = {}
				self.from_plugin = {:config => Hash.new { |hash, key| hash[key] = [] }}
				self.direct = Hash.new { |hash, key| hash[key] = Page.new }
				self.dynamic = Hash.new { |hash, key| hash[key] = Page.new }
				self.redirects = {}
				self.internal = Internal.new
				@plugins = {:direct => Hash.new { |hash, key| hash[key] = [] }, :dynamic => Hash.new { |hash, key| hash[key] = [] }}
			end
		end
	end
end
