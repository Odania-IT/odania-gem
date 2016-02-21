module Odania
	module Config
		class SubDomain < PageBase
			attr_accessor :name, :config, :dynamic, :internal, :from_plugin, :redirects

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

			def get_redirects
				return {} if self.redirects.nil?
				self.redirects
			end

			def plugins(type, key)
				@plugins[type][key]
			end

			def assets
				self.internal.assets
			end

			def dump
				result = super

				result['redirects'] = self.redirects
				result['config'] = self.config
				result['internal'] = self.internal.dump
				result
			end

			def load(data)
				reset
				super(data, nil)
				self.add(data)
			end

			def add(data, group_name=nil)
				duplicates = super(data, group_name)

				self.config = data['config'] unless data['config'].nil?

				self.internal.load(data['internal'], group_name) unless data['internal'].nil?
				unless data['redirects'].nil?
					data['redirects'].each_pair do |src_url, target_url|
						duplicates[:redirect] << src_url if self.redirects.key? src_url
						self.redirects[src_url] = target_url
					end
				end

				duplicates
			end

			private

			def reset
				super
				self.config = {}
				self.from_plugin = {:config => Hash.new { |hash, key| hash[key] = [] }}
				self.redirects = {}
				self.internal = Internal.new
			end
		end
	end
end
