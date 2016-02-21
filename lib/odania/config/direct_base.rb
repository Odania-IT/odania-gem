module Odania
	module Config
		class DirectBase
			attr_accessor :direct

			def initialize
				reset
			end

			def load(data, group_name)
				unless data['direct'].nil?
					data['direct'].each_pair do |name, direct_data|
						self.direct[name].load(direct_data, group_name)
					end
				end
			end

			def reset
				self.direct = Hash.new { |hash, key| hash[key] = Page.new }
			end

			def dump_direct_data
				direct_data = {}
				direct.each_pair do |web_url, page|
					direct_data[web_url] = page.dump
				end
				direct_data
			end
		end
	end
end
