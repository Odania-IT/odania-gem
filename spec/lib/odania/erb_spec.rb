describe Odania::Erb do
	context 'render simple template' do
		let(:subject) {
			Odania::Erb.new('This is a very simple template', 'example.com', {}, 'odania-test', 'test.odania.com')
		}

		let(:global_cfg) {
			JSON.parse File.read("#{BASE_DIR}/spec/fixtures/global_config.json")
		}

		it 'renders simple template' do
			$consul_mock.config.set('global_plugins_config', global_cfg)
			expect(subject.render).to eq('This is a very simple template')
		end
	end
end
