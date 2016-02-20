module Odania
	module Config
		class Duplicates
			def initialize
				@duplicates = Hash.new { |hash, key| hash[key] = Duplicate.new }
			end

			def add(type, key, group_name)
				@duplicates[type].add(key, group_name)
			end

			def duplicates
				@duplicates
			end

			class Duplicate
				def initialize
					@duplicate = {}
				end

				def add(key, group_name)
					@duplicate[key] = [] if @duplicate[key].nil?
					@duplicate[key] << group_name
				end
			end
		end
	end
end
