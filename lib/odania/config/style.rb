module Odania
	module Config
		class Style
			attr_accessor :name, :entry_point

			def initialize(name)
				self.name = name
				reset
			end

			def plugins(type, key)
				@plugins[type][key]
			end

			def dump
				result = super

				result['entry_point'] = entry_point
				result
			end

			def load(data, group_name)
				reset
				super(data, group_name)
				self.entry_point = data['entry_point'] unless data['entry_point'].nil?
			end

			private

			def reset
				super
				self.entry_point = nil
			end
		end
	end
end
