module Odania
	module Config
		class Internal
			attr_accessor :partials, :layouts

			def initialize
				reset
			end

			def load(data)
				reset
				unless data['partials'].nil?
					data['partials'].each_pair do |name, data|
						self.partials[name].load(data)
					end
				end

				unless data['layouts'].nil?
					data['layouts'].each_pair do |name, data|
						self.layouts[name].load(data)
					end
				end
			end

			def dump
				partial_data = {}
				partials.each_pair do |web_url, page|
					partial_data[web_url] = page.dump
				end

				layout_data = {}
				layouts.each_pair do |web_url, page|
					layout_data[web_url] = page.dump
				end

				{
					'layouts' => layout_data,
					'partials' => partial_data
				}
			end

			def reset
				self.layouts = Hash.new { |hash, key| hash[key] = Layout.new }
				self.partials = Hash.new { |hash, key| hash[key] = Page.new }
			end
		end
	end
end
