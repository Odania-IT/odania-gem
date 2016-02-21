module Odania
	class GenerateSiteAssetsVcl
		attr_accessor :domain, :template, :default_subdomains

		def default_subdomain_for(domain)
			return self.default_subdomains[domain.name] unless self.default_subdomains[domain.name].nil?
			return self.default_subdomains['_general'] unless self.default_subdomains['_general'].nil?
			'www'
		end

		def template_url_for(domain, page)
			"&domain=#{domain.name}"+
			"&plugin_url=#{page.plugin_url.nil? ? '/' : page.plugin_url}"+
			"&group_name=#{Odania.varnish_sanitize(page.group_name)}"
		end

		def prepare_url(url)
			return "/#{url}" unless '/'.eql? url[0]
			url
		end

		def general_subdomain
			self.domain['_general']
		end

		def initialize(domain, default_subdomains)
			self.domain = domain
			self.default_subdomains = default_subdomains
			self.template = File.new("#{BASE_DIR}/templates/varnish/site_assets.vcl.erb").read
			self.template = File.new("#{BASE_DIR}/templates/varnish/general_site_assets.vcl.erb").read if '_general'.eql? domain.name
		end

		def render
			Erubis::Eruby.new(self.template).result(binding)
		end

		def write(out_dir)
			File.write("#{out_dir}/sites/#{self.domain.name}_assets.vcl", self.render)
		end
	end
end
