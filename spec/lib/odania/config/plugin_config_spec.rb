describe Odania::Config::PluginConfig do
	let(:cfg) {
		JSON.parse File.read("#{BASE_DIR}/spec/fixtures/plugin_config_1.json")
	}

	context 'configuration' do
		it 'should be valid' do
			expect(subject.config).to be_a(Hash)
			expect(subject.domains).to be_a(Hash)
			subject.domains.each_pair do |domain, data|
				expect(data).to be_a(Odania::Config::Domain)
			end
		end

		it 'loads configuration' do
			expect(subject.load(cfg)).to be(true)

			expect(subject.config).to eql(cfg['config'])
			expect(subject.plugin_config).to eql(cfg['plugin-config'])
			expect(subject.domains.keys).to eql(cfg['domains'].keys)
		end

		it 'dumps the same config' do
			expect(subject.load(cfg)).to be(true)
			expect(subject.dump).to eql(cfg)
		end
	end
end
