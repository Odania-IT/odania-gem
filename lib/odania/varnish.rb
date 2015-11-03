require_relative 'varnish/generators/generate_backend_vcl'
require_relative 'varnish/generators/generate_catch_all_vcl'
require_relative 'varnish/generators/generate_default_vcl'
require_relative 'varnish/generators/generate_general_vcl'
require_relative 'varnish/generators/generate_redirects_vcl'
require_relative 'varnish/generators/generate_sites_vcl'

module Odania
	class Varnish
		def generate(out_dir='/etc/varnish')
			FileUtils.mkdir_p out_dir unless File.directory? out_dir
			global_config = Odania.plugin.get_global_config
			plugin_config = Odania.plugin.plugin_config.load_global_config global_config

			# Backend config
			backend_groups = plugin_config.backend_groups
			default_backend = plugin_config.default_backend

			# Domain information config
			domains = plugin_config.domains
			default_subdomains = plugin_config.default_subdomains

			# Generate catch all vcl
			gen = GenerateCatchAllVcl.new
			gen.write(out_dir)

			# Generate catch all vcl
			gen = GenerateGeneralVcl.new
			gen.write(out_dir)

			# Generate backend vcl
			gen = GenerateBackendVcl.new(default_backend, backend_groups)
			gen.write(out_dir)

			# Generate vcl_recv
			gen = GenerateSitesVcl.new(domains, default_subdomains)
			gen.write(out_dir)

			# Generate global redirects
			gen = GenerateRedirectsVcl.new(plugin_config.redirects)
			gen.write(out_dir)

			# Generate main vcl
			gen = GenerateDefaultVcl.new
			gen.write(out_dir)

			puts
			puts 'Registering internal varnish plugin'
			register_plugin
			puts
		end

		 def reload_config
			 puts 'Updating varnish config'
			 current_number = 0
			 current_number = File.read('/tmp/current_varnish_config_number').to_i if File.exists? '/tmp/current_varnish_config_number'
			 current_number += 1
			 File.write '/tmp/current_varnish_config_number', current_number

			 cmd = "varnishadm vcl.load reload#{current_number} /etc/varnish/default.vcl"
			 puts "CMD: #{cmd}"
			 puts `#{cmd}`
			 cmd = "varnishadm vcl.use reload#{current_number}"
			 puts "CMD: #{cmd}"
			 puts `#{cmd}`
		 end

		private

		def register_plugin
			plugin_config = JSON.parse File.read "#{BASE_DIR}/config/varnish_config.json"

			ips = Odania.ips
			plugin_config['ips'] = ips
			plugin_config['ip'] = ips.first
			plugin_config['port'] = 80
			plugin_config['tags'] = ["plugin-#{get_plugin_name}"]
			puts JSON.pretty_generate plugin_config if $debug

			plugin_instance_name = Odania.plugin.get_plugin_instance_name get_plugin_name
			Odania.plugin.register plugin_instance_name, plugin_config
		end

		def get_plugin_name
			'odania_varnish'
		end
	end
end
