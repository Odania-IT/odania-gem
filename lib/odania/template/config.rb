module Odania
	module Template
		class Config
			attr_accessor :config

			def initialize
				self.config = Hash.new
			end

			def get(key)
				self.config[key]
			end
		end
	end
end
