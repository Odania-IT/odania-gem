module Odania
	module Template
		class Asset
			attr_accessor :assets

			def initialize
				self.assets = Hash.new
			end

			def get(key)
				self.assets[key]
			end
		end
	end
end
