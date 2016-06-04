module Odania
	module Config
		class PageBase
			attr_accessor :assets, :partials

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

				unless data['partials'].nil?
					data['partials'].each_pair do |name, partial_data|
						duplicates[:partials] << name if self.partials.key? name
						self.partials[name].load(partial_data, group_name)
					end
				end
				duplicates
			end

			def load(data, group_name)
				self.add(data, group_name)
			end

			def reset
				self.assets = Hash.new { |hash, key| hash[key] = Page.new }
				self.partials = Hash.new { |hash, key| hash[key] = Page.new }

				@plugins = {:partials => Hash.new { |hash, key| hash[key] = [] }, :assets => Hash.new { |hash, key| hash[key] = [] }}
			end

			def [](type)
				type = type.to_sym
				return self.assets if :assets.eql? type
				self.partials
			end

			def dump
				asset_data = {}
				assets.each_pair do |web_url, page|
					asset_data[web_url] = page.dump
				end

				partial_data = {}
				partials.each_pair do |web_url, page|
					partial_data[web_url] = page.dump
				end

				{
					'assets' => asset_data,
					'partials' => partial_data
				}
			end
		end
	end
end
