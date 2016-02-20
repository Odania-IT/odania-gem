module Odania
	class Erb
		attr_accessor :variables, :config, :page, :asset

		def initialize(template, domain, partials, group_name, req_host)
			@template = template

			self.variables = Variables.new(template, domain, partials, group_name, req_host)
			self.config = Config.new self.variables
			self.page = Page.new self.variables
			self.asset = Asset.new self.variables

			if LOCAL_TEST_MODE
				data = "\n<!-- Domain: #{domain} -->"
				data += "\n<!-- Group Name: #{group_name} -->"
				data += "\n<!-- Request Host: #{req_host} -->"
				data += "\n<!-- Base Domain: #{self.variables.base_domain} -->"
				data += "\n<!-- Partials: #{JSON.pretty_generate(self.variables.partials)} -->"
				data += "\n<!-- Config: #{JSON.pretty_generate(self.variables.config)} -->"
				data += "\n<!-- SubDomain Config: #{JSON.pretty_generate(self.variables.subdomain_config)} -->"
				#data += "\n<!-- Global Config: #{JSON.pretty_generate(self.variables.global_config)} -->"
				@template += data.html_safe
			end
		end

		def render
			ERB.new(@template).result(binding)
		end

		class Variables
			attr_accessor :template, :config, :subdomain_config, :global_config, :domain
			attr_accessor :base_domain, :partials, :group_name, :req_host

			def initialize(template, domain, partials, group_name, req_host)
				self.template = template
				self.global_config = Odania.plugin.get_global_config

				domain_info = PublicSuffix.parse(domain)
				self.config, self.base_domain = Odania.plugin.get_domain_config_for domain_info.domain, self.global_config
				self.subdomain_config = self.config[domain_info.trd] unless domain_info.trd.nil?
				self.subdomain_config = self.config['_general'] if self.subdomain_config.nil?
				self.subdomain_config = {} if self.subdomain_config.nil?

				self.domain = domain
				self.partials = partials
				self.group_name = group_name
				self.req_host = req_host
			end

			def get_partial(page)
				get_specific %w(internal partials), page
			end

			def get_config_key(key)
				get_specific %w(config), key
			end

			def notify_error_async(type, key, data)
				data = {
					domain: self.domain,
					base_domain: self.base_domain,
					group_name: self.group_name,
					req_host: self.req_host,
					type: type,
					key: key,
					data: data
				}
				ProcessErrorJob.perform_later data
			end

			private

			def get_specific(part, page)
				subdomain = req_host.gsub(".#{domain}", '')

				# subdomain specific layouts
				result = retrieve_hash_path global_config, ['domains', domain, subdomain] + part + [page]
				return result unless result.nil?

				# domain specific layouts
				result = retrieve_hash_path global_config, ['domains', domain, '_general'] + part + [page]
				return result unless result.nil?

				# general layouts
				result = retrieve_hash_path global_config, %w(domains _general _general) + part + [page]
				return result unless result.nil?

				nil
			end

			def retrieve_hash_path(hash, path)
				key = path.shift

				return nil until hash.has_key? key
				return hash[key] if path.empty?
				retrieve_hash_path hash[key], path
			end
		end

		class Config
			def initialize(variables)
				@variables = variables
			end

			def get(key)
				val = @variables.get_config_key(key)
				return val unless val.nil?
				"--- Config Key Not found: #{key} ---"

				@variables.notify_error_async :config, 'Key not found', key
			end
		end

		class Page
			def initialize(variables)
				@variables = variables
			end

			def get(page)
				if not @variables.partials[page].nil?
					"<!-- Page: #{page} -->\n<esi:include src=\"#{@variables.partials[page]}\"/>\n<!-- End Page: #{page} -->"
				else
					partial = @variables.get_partial(page)

					if partial.nil?
						#"<!-- Page: #{page} -->\n<esi:include src=\"http://internal.core/template/partial/#{page}?domain=#{@variables.domain}&group_name=#{@variables.group_name}\"/>\n<!-- End Page: #{page} -->"
						"\n\n\n<pre>UNHANDLED PAGE: #{page} !!!!!!!!!!!!!!!!!!!!</pre>\n\n\n"
					else
						"<!-- Page: #{page} -->\n<esi:include src=\"http://internal.core/template/partial/#{page}?domain=#{@variables.domain}&group_name=#{@variables.group_name}&plugin_url=#{partial['plugin_url']}&req_host=#{@variables.req_host}\"/>\n<!-- End Page: #{page} -->"
					end
				end
			end
		end

		class Asset
			def initialize(variables)
				@variables = variables
			end

			def get(asset)
				asset_url = get_asset_url(@variables.domain)
				asset_url = "//#{asset_url}" unless asset_url.include? '//'
				"#{asset_url}/#{asset}"
			end

			private

			def get_asset_url(domain)
				return @variables.subdomain_config['asset_url'] unless @variables.subdomain_config['asset_url'].nil?
				domain
			end
		end
	end
end
