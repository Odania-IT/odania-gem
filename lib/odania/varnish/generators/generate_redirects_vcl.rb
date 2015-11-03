module Odania
	class GenerateRedirectsVcl
		attr_accessor :redirects, :template

		def initialize(redirects)
			self.redirects = redirects
			self.template = File.new("#{BASE_DIR}/templates/varnish/redirects.vcl.erb").read
		end

		def render
			Erubis::Eruby.new(self.template).result(binding)
		end

		def write(out_dir)
			File.write("#{out_dir}/redirects.vcl", self.render)
		end
	end
end
