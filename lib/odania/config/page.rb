module Odania
	module Config
		class Page
			attr_accessor :group_name, :plugin_url, :cacheable, :expires

			def dump
				result = {}
				result['group_name'] = self.group_name unless self.group_name.nil?
				result['plugin_url'] = self.plugin_url unless self.plugin_url.nil?
				result['cacheable'] = self.cacheable unless self.cacheable.nil?
				result['expires'] = self.expires unless self.expires.nil?
				result
			end

			def load(data, group_name=nil)
				self.group_name = data['group_name'] unless data['group_name'].nil?
				self.group_name = group_name unless group_name.nil?
				self.plugin_url = data['plugin_url']
				self.cacheable = data['cacheable'] unless data['cacheable'].nil?
				self.expires = data['expires'] unless data['expires'].nil?
			end

			def director
				puts self.inspect if self.group_name.nil?
				"#{Odania.varnish_sanitize(self.group_name)}_director"
			end
		end
	end
end
