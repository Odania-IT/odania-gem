module Odania
	module Config
		class Domain
			attr_accessor :name, :subdomains, :config, :redirects

			def initialize(name)
				self.name = name
				reset
			end

			def add_subdomain(subdomain_name)
				self.subdomains[subdomain_name]
			end

			def subdomain(name)
				self.subdomains[name]
			end

			def dump
				subdomain_data = {}
				subdomains.each_pair do |name, subdomain|
					subdomain_data[name] = subdomain.dump
				end
				subdomain_data
			end

			def load(data)
				self.name = data['name'] unless data['name'].nil?
				self.add(data)
			end

			def add(sub_domain_data, group_name=nil)
				duplicates = Hash.new { |hash, key| hash[key] = [] }
				unless sub_domain_data.nil?
					sub_domain_data.each_pair do |name, data|
						subdomain_duplicates = self.subdomains[name].add(data, group_name)
						duplicates.deep_merge! subdomain_duplicates
					end
				end

				duplicates
			end

			def [](key)
				self.subdomains[key]
			end

			private

			def reset
				self.subdomains = Hash.new { |hash, key| hash[key] = SubDomain.new(key) }
			end
		end
	end
end
