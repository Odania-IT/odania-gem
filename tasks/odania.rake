namespace :odania do
	namespace :global do
		desc 'Generate the global config'
		task :generate_config do
			puts 'Loading plugin configs from consul'
			Odania.plugin.plugin_config.load_from_consul

			puts 'Generating global config'
			Odania.plugin.plugin_config.generate
		end
	end
end
