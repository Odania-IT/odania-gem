module Odania
	module Config
		class Style < DirectBase
			attr_accessor :name, :entry_point, :dynamic, :assets

			def initialize(name)
				self.name = name
				reset
			end

			def plugins(type, key)
				@plugins[type][key]
			end

			def dump
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
					'direct' => dump_direct_data,
					'dynamic' => dynamic_data,
					'assets' => asset_data
				}
			end

			def load(data, group_name)
				reset
				super(data, group_name)
				self.entry_point = data['entry_point'] unless data['entry_point'].nil?

				unless data['dynamic'].nil?
					data['dynamic'].each_pair do |name, dynamic_data|
						self.dynamic[name].load(dynamic_data, group_name)
					end
				end

				unless data['assets'].nil?
					data['assets'].each_pair do |name, asset_data|
						self.assets[name].load(asset_data, group_name)
					end
				end
			end

			private

			def reset
				super
				self.entry_point = nil
				self.dynamic = Hash.new { |hash, key| hash[key] = Page.new }
				self.assets = Hash.new { |hash, key| hash[key] = Page.new }
				@plugins = {:direct => Hash.new { |hash, key| hash[key] = [] }, :dynamic => Hash.new { |hash, key| hash[key] = [] }}
			end
		end
	end
end
