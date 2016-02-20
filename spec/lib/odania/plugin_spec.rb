describe Odania::Plugin do
	context 'services' do
		let(:subject) {
			Odania::Plugin.new($consul_mock)
		}

		let(:cfg) {
			JSON.parse File.read("#{BASE_DIR}/spec/fixtures/plugin_config_1.json")
		}

		it 'registers a plugin' do
			cfg_name = cfg['plugin-config']['name']
			instance_name = 'cfg_instance_1'
			key_name = "#{cfg_name}|#{instance_name}"
			expect(subject.register(instance_name, cfg)).to eql(key_name)
			expect($consul_mock.configuration["plugins_config/#{cfg_name}"]).to eql(cfg)
		end

		it 'deregisters a plugin' do
			instance_name = 'cfg_instance_1'
			subject.register(instance_name, cfg)
			expect(subject.deregister(instance_name)).to be_truthy
		end
	end
end
