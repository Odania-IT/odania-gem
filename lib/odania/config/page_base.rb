module Odania
	module Config
		class PageBase
			attr_accessor :assets

			def initialize
				reset
			end

			def add(data, group_name=nil)
				duplicates = Hash.new { |hash, key| hash[key] = [] }
				unless data['assets'].nil?
					data['assets'].each_pair do |name, asset_data|
						duplicates[:assets] << name if self.assets.key? name
						self.assets[name].load(asset_data, group_name)
					end
				end
				duplicates
			end

			def load(data, group_name)
				self.add(data, group_name)
			end

			def reset
				self.assets = Hash.new { |hash, key| hash[key] = Page.new }

				@plugins = {:assets => Hash.new { |hash, key| hash[key] = [] }}
			end

			def [](type)
				self.assets
			end

			def dump
				asset_data = {}
				assets.each_pair do |web_url, page|
					asset_data[web_url] = page.dump
				end

				{
					'assets' => asset_data
				}
			end
		end
	end
end
