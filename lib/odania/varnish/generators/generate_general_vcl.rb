module Odania
	class GenerateGeneralVcl
		attr_accessor :template

		def initialize
			self.template = File.new("#{BASE_DIR}/templates/varnish/general.vcl.erb").read
		end

		def render
			Erubis::Eruby.new(self.template).result(binding)
		end

		def write(out_dir)
			File.write("#{out_dir}/general.vcl", self.render)
		end
	end
end
