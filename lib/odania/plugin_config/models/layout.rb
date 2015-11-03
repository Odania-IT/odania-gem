module Odania
	module PluginConfig
		class Layout
			attr_accessor :config

			def initialize
				@plugins = []
			end

			def set_config(config, plugin_name)
				result = true
				self.config = config
				result = false unless @plugins.empty?
				@plugins << plugin_name
				result
			end

			def plugins
				@plugins
			end

			def dump
				config
			end

			 def load(data)
				 self.config = data
			 end
		end
	end
end
