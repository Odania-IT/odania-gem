module Odania
	module Config
		class Layout
			attr_accessor :styles

			def initialize
				reset
			end

			def assets
				return {} if self.styles['_general'].nil? or self.styles['_general'].assets.nil?
				self.styles['_general'].assets
			end

			def dump
				style_data = {}
				styles.each_pair do |name, style|
					style_data[name] = style.dump
				end

				result = {}
				result['styles'] =style_data unless style_data.nil?
				result
			end

			def load(data, group_name)
				reset
				unless data['styles'].nil?
					data['styles'].each_pair do |key, val|
						self.styles[key].load(val, group_name)
					end
				end
			end

			def reset
				self.styles = Hash.new { |hash, key| hash[key] = Style.new(key) }
			end
		end
	end
end
