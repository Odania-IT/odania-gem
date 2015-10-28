module Odania
	module Template
		class Page
			attr_accessor :pages

			def initialize
				self.pages = Hash.new
			end

			def get(key)
				self.pages[key]
			end
		end
	end
end
