module Odania
	class GenerateFinalVcl
		attr_accessor :template

		def initialize
			self.template = File.new("#{BASE_DIR}/templates/varnish/final.vcl.erb").read
		end

		def render
			Erubis::Eruby.new(self.template).result(binding)
		end

		def write(out_dir)
			File.write("#{out_dir}/final.vcl", self.render)
		end
	end
end
