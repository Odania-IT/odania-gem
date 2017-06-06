require 'elasticsearch'

config = YAML.load(ERB.new(File.read(File.join(Rails.root, 'config', 'elasticsearch.yml'))).result)
el_config = config[Rails.env]
$elasticsearch = Elasticsearch::Client.new log: true, hosts: el_config['hosts'], user: el_config['user'], password: el_config['password'], scheme: el_config['scheme']
