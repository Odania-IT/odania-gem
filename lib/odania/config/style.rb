module Odania
	module Config
		class Style
			attr_accessor :name, :entry_point, :direct, :dynamic, :assets

			def initialize(name)
				self.name = name
				reset
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

				asset_data = {}
				assets.each_pair do |asset_url, page|
					asset_data[asset_url] = page.dump
				end

				{
					'entry_point' => entry_point,
					'direct' => direct_data,
					'dynamic' => dynamic_data,
					'assets' => asset_data
				}
			end

			def load(data, group_name)
				reset
				self.entry_point = data['entry_point'] unless data['entry_point'].nil?

				unless data['direct'].nil?
					data['direct'].each_pair do |name, data|
						self.direct[name].load(data, group_name)
					end
				end

				unless data['dynamic'].nil?
					data['dynamic'].each_pair do |name, data|
						self.dynamic[name].load(data, group_name)
					end
				end

				unless data['assets'].nil?
					data['assets'].each_pair do |name, data|
						self.assets[name].load(data, group_name)
					end
				end
			end

			private

			def reset
				self.entry_point = nil
				self.direct = Hash.new { |hash, key| hash[key] = Page.new }
				self.dynamic = Hash.new { |hash, key| hash[key] = Page.new }
				self.assets = Hash.new { |hash, key| hash[key] = Page.new }
				@plugins = {:direct => Hash.new { |hash, key| hash[key] = [] }, :dynamic => Hash.new { |hash, key| hash[key] = [] }}
			end
		end
	end
end
