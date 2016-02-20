require_relative 'generate_site_vcl'

module Odania
	class GenerateSitesVcl
		attr_accessor :domains, :template, :default_subdomains

		def initialize(domains, default_subdomains)
			self.domains = domains
			self.default_subdomains = default_subdomains
			self.template = File.new("#{BASE_DIR}/templates/varnish/sites.vcl.erb").read
		end

		def render
			Erubis::Eruby.new(self.template).result(binding)
		end

		def write(out_dir)
			File.write("#{out_dir}/sites.vcl", self.render)

			Dir.mkdir "#{out_dir}/sites" unless File.directory? "#{out_dir}/sites"
			self.domains.each_pair do |domain_name, domain|
				out = GenerateSiteVcl.new(domain, default_subdomains)
				out.write out_dir
			end
		end
	end
end
