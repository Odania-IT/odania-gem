module Odania
	class GenerateSiteAssetsVcl
		attr_accessor :domain, :assets, :template

		def initialize(domain)
			self.domain = domain
			self.template = File.new("#{BASE_DIR}/templates/varnish/site_assets.vcl.erb").read

			self.assets = Hash.new { |hash, key| hash[key] = Odania::PluginConfig::SubDomain.new(key) }
			domain.subdomains.each_pair do |subdomain_name, subdomain|
				asset_domain = subdomain.config['asset_url'].nil? ? "#{subdomain.name}.#{domain.name}" : subdomain.config['asset_url']

				subdomain.assets.each_pair do |src, page|
					self.assets[asset_domain].assets[src] = page
				end
			end
		end

		def render
			Erubis::Eruby.new(self.template).result(binding)
		end

		def write(out_dir)
			File.write("#{out_dir}/sites/#{self.domain.name}_assets.vcl", self.render)
		end
	end
end
