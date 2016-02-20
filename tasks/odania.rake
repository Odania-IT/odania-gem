namespace :odania do
	namespace :global do
		desc 'Generate the global config'
		task :generate_config do
			Odania.plugin.plugin_config.generate_global_config
		end
	end
end
