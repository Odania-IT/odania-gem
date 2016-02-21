module Odania
	module Config
		class Style < PageBase
			attr_accessor :name, :entry_point, :dynamic, :assets

			def initialize(name)
				self.name = name
				reset
			end

			def plugins(type, key)
				@plugins[type][key]
			end

			def dump
				result = super

				asset_data = {}
				assets.each_pair do |asset_url, page|
					asset_data[asset_url] = page.dump
				end

				result['entry_point'] = entry_point
				result['assets'] = asset_data
				result
			end

			def load(data, group_name)
				reset
				super(data, group_name)
				self.entry_point = data['entry_point'] unless data['entry_point'].nil?

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
				self.assets = Hash.new { |hash, key| hash[key] = Page.new }
			end
		end
	end
end
