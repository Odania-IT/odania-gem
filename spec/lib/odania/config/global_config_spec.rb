describe Odania::Config::GlobalConfig do
	let(:cfg1) {
		JSON.parse File.read("#{BASE_DIR}/spec/fixtures/plugin_config_1.json")
	}
	let(:global_cfg) {
		JSON.parse File.read("#{BASE_DIR}/spec/fixtures/global_config.json")
	}

	context 'configuration' do
		it 'add configuration' do
			expect(subject.add_plugin_config(cfg1)).to be(true)

			cfg_result = subject.dump
			expect(cfg_result['domains']['example.com']['www']['redirects']).to eql(cfg1['domains']['example.com']['www']['redirects'])
			expect(cfg_result['domains']['example.com']['www']['config']).to eql(cfg1['domains']['example.com']['www']['config'])

			cfg1['domains']['example.com']['www']['direct'].each_pair do |path, data|

				expect(cfg_result['domains']['example.com']['www']['direct'][path]['plugin_url']).to eql(data['plugin_url'])
			end

		end

		it 'detects duplicates' do
			expect(subject.add_plugin_config(cfg1)).to be(true)
			expect(subject.duplicates).to be_empty
			expect(subject.add_plugin_config(cfg1)).to be(true)

			duplicates = subject.duplicates
			expect(subject.duplicates).not_to be_empty
			expect(duplicates).to have_key(:config)
			expect(duplicates).to have_key(:direct)
			expect(duplicates).to have_key(:redirect)
		end

		it 'generate global configuration' do
			cfg_name = cfg1['plugin-config']['name']
			$consul_mock.config.set("plugins_config/#{cfg_name}", cfg1)

			$consul_mock.service.services = {
				cfg_name => [
					OpenStruct.new({
						'Node' => 'agent-one',
						'Address' => '172.20.20.1',
						'ServiceID' => "#{cfg_name}_1",
						'ServiceName' => cfg_name,
						'ServiceTags' => [],
						'ServicePort' => 80,
						'ServiceAddress' => '172.20.20.1'
					}),
					OpenStruct.new({
						'Node' => 'agent-two',
						'Address' => '172.20.20.2',
						'ServiceID' => "#{cfg_name}_2",
						'ServiceName' => cfg_name,
						'ServiceTags' => [],
						'ServicePort' => 80,
						'ServiceAddress' => '172.20.20.1'
					})
				]
			}

			global_config = subject.generate_global_config
			expect(global_config).not_to be_empty
		end
	end
end
