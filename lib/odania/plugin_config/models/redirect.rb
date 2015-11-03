module Odania
	module PluginConfig
		class Redirect
			attr_accessor :src, :target, :plugins

			def initialize(src)
				self.src = src
				self.plugins = []
			end

			def add(target, plugin_name)
				self.target = target
				self.plugins << plugin_name

				return false if self.plugins.count > 1
				true
			end
		end
	end
end
