module Odania
	module PluginConfig
		class SubDomain
			attr_accessor :name, :pages, :config, :assets, :from_plugin

			def initialize(name)
				self.name = name
				self.config = {}
				self.from_plugin = {:config => Hash.new { |hash, key| hash[key] = [] }}
				self.pages = Hash.new { |hash, key| hash[key] = Page.new }
				self.assets = Hash.new { |hash, key| hash[key] = Page.new }
				@plugins = {:page => Hash.new { |hash, key| hash[key] = [] }, :asset => Hash.new { |hash, key| hash[key] = [] }}
			end

			def set_config(config_data, group_name)
				errors = []
				config_data.each_pair do |key, val|
					from_plugin[:config][key] << group_name
					errors << {:type => :config, :plugins => from_plugin[:config][key], :key => key} unless config[key].nil?
					config[key] = val
				end
				errors
			end

			def add_page(web_url, group_name, plugin_url, plugin_name)
				result = true
				result = false unless self.assets.key? web_url
				self.pages[web_url].group_name = group_name
				self.pages[web_url].plugin_url = plugin_url
				@plugins[:page][web_url] << plugin_name
				result
			end

			def add_asset(web_url, group_name, plugin_url, plugin_name)
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
				page_data = {}
				pages.each_pair do |web_url, page|
					page_data[web_url] = page.dump
				end

				asset_data = {}
				assets.each_pair do |web_url, page|
					asset_data[web_url] = page.dump
				end

				{
					'name' => name,
					'config' => config,
					'pages' => page_data,
					'assets' => asset_data
				}
			end

			def load(data)
				reset
				self.config = data['config']

				unless data['pages'].nil?
					data['pages'].each_pair do |name, data|
						self.pages[name].load(data)
					end
				end

				unless data['assets'].nil?
					data['assets'].each_pair do |name, data|
						self.assets[name].load(data)
					end
				end
			end

			private

			def reset
				self.from_plugin = {:config => Hash.new { |hash, key| hash[key] = [] }}
				self.pages = Hash.new { |hash, key| hash[key] = Page.new }
				self.assets = Hash.new { |hash, key| hash[key] = Page.new }
				@plugins = {:page => Hash.new { |hash, key| hash[key] = [] }, :asset => Hash.new { |hash, key| hash[key] = [] }}
			end
		end
	end
end
