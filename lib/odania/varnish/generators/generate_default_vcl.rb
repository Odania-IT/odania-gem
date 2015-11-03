module Odania
	class GenerateDefaultVcl
		attr_accessor :template

		def initialize
			self.template = File.new("#{BASE_DIR}/templates/varnish/default.vcl.erb").read
		end

		def render
			Erubis::Eruby.new(self.template).result(binding)
		end

		def write(out_dir)
			File.write("#{out_dir}/default.vcl", self.render)
		end
	end
end
