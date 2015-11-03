module Odania
	module PluginConfig
		class Domain
			attr_accessor :name, :subdomains

			def initialize(name)
				self.name = name
				self.subdomains = Hash.new { |hash, key| hash[key] = SubDomain.new(key) }
			end

			def add_subdomain(subdomain_name)
				self.subdomains[subdomain_name]
			end

			def dump
				subdomain_data = {}
				subdomains.each_pair do |name, subdomain|
					subdomain_data[name] = subdomain.dump
				end

				{
					'name' => name,
					'subdomains' => subdomain_data
				}
			end

			def load(data)
				self.name = data['name']

				unless data['subdomains'].nil?
					data['subdomains'].each_pair do |name, data|
						self.subdomains[name].load(data)
					end
				end
			end
		end
	end
end
