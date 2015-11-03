module Odania
	module Template
		class Page
			attr_accessor :pages

			def initialize
				self.pages = Hash.new
			end

			def get(key)
				"<esi:include src=\"/cgi-bin/date.cgi\"/>"
				self.pages[key]
			end
		end
	end
end
