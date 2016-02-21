module Odania
	class GenerateSiteAssetsVcl < GenerateSiteVcl

		def initialize(domain, default_subdomains)
			super(domain, default_subdomains)
			self.template = File.new("#{BASE_DIR}/templates/varnish/site_assets.vcl.erb").read
			self.template = File.new("#{BASE_DIR}/templates/varnish/general_site_assets.vcl.erb").read if '_general'.eql? domain.name
		end

		def write(out_dir)
			File.write("#{out_dir}/sites/#{self.domain.name}_assets.vcl", self.render)
		end
	end
end
