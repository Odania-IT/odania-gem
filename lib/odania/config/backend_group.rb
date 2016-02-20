module Odania
	module Config
		class BackendGroup
			attr_accessor :name, :backends, :core_backend

			def initialize(name, backends=[])
				self.name = name
				self.core_backend = false
				self.backends = backends
			end

			def add_backend(backend)
				self.backends << backend
			end

			def check_core_backend(tags)
				self.core_backend = tags.include?('core-backend')
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
