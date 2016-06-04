module Odania
	module Config
		class Layout < PageBase
			attr_accessor :config

			def initialize
				reset
			end

			def dump
				result = super
				result['config'] = config unless config.nil?
				result
			end

			def load(data, group_name)
				reset
				super(data, group_name)
				unless data['config'].nil?
					self.config = data['config']
				end
			end

			def reset
				super
				self.config = {}
			end
		end
	end
end
