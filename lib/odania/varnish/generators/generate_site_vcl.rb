module Odania
	class GenerateSiteVcl
		attr_accessor :domain, :template, :default_subdomains

		def default_subdomain_for(domain)
			return self.default_subdomains[domain.name] unless self.default_subdomains[domain.name].nil?
			return self.default_subdomains['_general'] unless self.default_subdomains['_general'].nil?
			'www'
		end

		def initialize(domain, default_subdomains)
			self.domain = domain
			self.default_subdomains = default_subdomains
			self.template = File.new("#{BASE_DIR}/templates/varnish/site.vcl.erb").read
		end

		def render
			Erubis::Eruby.new(self.template).result(binding)
		end

		def write(out_dir)
			File.write("#{out_dir}/sites/#{self.domain.name}.vcl", self.render)
		end
	end
end
