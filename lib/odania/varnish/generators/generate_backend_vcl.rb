module Odania
	class GenerateBackendVcl
		attr_accessor :default_backend, :backend_groups, :template

		def initialize(default_backend, backend_groups)
			self.default_backend = default_backend
			self.backend_groups = backend_groups
			self.template = File.new("#{BASE_DIR}/templates/varnish/backend.vcl.erb").read
		end

		def core_backends
			core_backends = []
			self.backend_groups.each_pair do |group_name, backend_group|
				if backend_group.core_backend
					backend_group.backends.each do |backend|
						core_backends << "#{Odania.varnish_sanitize(group_name)}_#{Odania.varnish_sanitize(backend.instance_name)}"
					end
				end
			end
			core_backends
		end

		def render
			Erubis::Eruby.new(self.template).result(binding)
		end

		def write(out_dir)
			File.write("#{out_dir}/backend.vcl", self.render)
		end
	end
end
