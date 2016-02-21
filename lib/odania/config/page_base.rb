module Odania
	module Config
		class PageBase
			attr_accessor :direct, :dynamic

			def initialize
				reset
			end

			def add(data, group_name=nil)
				duplicates = Hash.new { |hash, key| hash[key] = [] }
				unless data['direct'].nil?
					data['direct'].each_pair do |name, direct_data|
						duplicates[:direct] << name if self.direct.key? name
						self.direct[name].load(direct_data, group_name)
					end
				end

				unless data['dynamic'].nil?
					data['dynamic'].each_pair do |name, dynamic_data|
						duplicates[:dynamic] << name if self.direct.key? name
						self.dynamic[name].load(dynamic_data, group_name)
					end
				end
				duplicates
			end

			def load(data, group_name)
				self.add(data, group_name)
			end

			def reset
				self.direct = Hash.new { |hash, key| hash[key] = Page.new }
				self.dynamic = Hash.new { |hash, key| hash[key] = Page.new }

				@plugins = {:direct => Hash.new { |hash, key| hash[key] = [] }, :dynamic => Hash.new { |hash, key| hash[key] = [] }}
			end

			def [](type)
				return self.direct if 'direct'.eql? type.to_s
				self.dynamic
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
					'direct' => direct_data,
					'dynamic' => dynamic_data
				}
			end
		end
	end
end
