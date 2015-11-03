module Odania
	class GenerateBackendVcl
		attr_accessor :default_backend, :backend_groups, :template

		def initialize(default_backend, backend_groups)
			self.default_backend = default_backend
			self.backend_groups = backend_groups
			self.template = File.new("#{BASE_DIR}/templates/varnish/backend.vcl.erb").read
		end

		def render
			Erubis::Eruby.new(self.template).result(binding)
		end

		def write(out_dir)
			File.write("#{out_dir}/backend.vcl", self.render)
		end
	end
end
