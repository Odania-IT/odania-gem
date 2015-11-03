module Odania
	module PluginConfig
		class Page
			attr_accessor :group_name, :plugin_url

			def dump
				{
					'group_name' => group_name,
					'plugin_url' => plugin_url
				}
			end

			def load(data)
				self.group_name = data['group_name']
				self.plugin_url = data['plugin_url']
			end

			 def director
				 "#{Odania.varnish_sanitize(group_name)}_director"
			 end
		end
	end
end
