module Odania
	class Consul
		protected

		def retrieve_value(plugin_path)
			begin
				Diplomat::Kv.get(plugin_path, :recurse => true)
			rescue Diplomat::KeyNotFound
				[]
			end
		end
	end
end
