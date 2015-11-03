module Odania
	module PluginConfig
		class BackendGroup
			attr_accessor :name, :backends

			def initialize(name, backends=[])
				self.name = name
				self.backends = backends
			end

			def add_backend(backend)
				self.backends << backend
			end

			def dump
				backend_data = []
				backends.each do |backend|
					backend_data << backend.dump
				end

				{
					'name' => name,
					'backends' => backend_data
				}
			end

			def load(data)
				self.name = data['name']

				unless data['backends'].nil?
					data['backends'].each do |data|
						self.backends << Backend.new.load(data)
					end
				end
			end
		end
	end
end
