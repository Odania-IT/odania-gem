describe Odania::Varnish do
	context 'generate' do
		before do
			$consul_mock.service.services = {
				'odania_static' => [
					OpenStruct.new({
						'Node' => 'agent-one',
						'Address' => '172.20.20.1',
						'ServiceID' => 'odania_static_1',
						'ServiceName' => 'odania_static',
						'ServiceTags' => [],
						'ServicePort' => 80,
						'ServiceAddress' => '172.20.20.1'
					}),
					OpenStruct.new({
						'Node' => 'agent-two',
						'Address' => '172.20.20.2',
						'ServiceID' => 'odania_static_2',
						'ServiceName' => 'odania_static',
						'ServiceTags' => [],
						'ServicePort' => 80,
						'ServiceAddress' => '172.20.20.1'
					})
				]
			}
		end

		let(:global_cfg) {
			JSON.parse File.read("#{BASE_DIR}/spec/fixtures/global_config.json")
		}

		it 'generates the varnish config' do
			$consul_mock.config.set('global_plugins_config', global_cfg)
			expect(subject.generate('/tmp/varnish')).to eq('odania-varnish|odania_varnish_1')
		end
	end
end
