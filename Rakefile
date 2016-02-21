require 'bundler/gem_tasks'
require_relative 'lib/odania'

Dir.glob('tasks/**/*.rake').each(&method(:import))

task :default => [:spec]
