require 'spec_helper'

describe Odania::Consul do
	subject { Odania::Consul.new }

	describe '#process' do
		let(:output) { subject.get_config }

		it 'retrieves config' do
			allow(subject).to receive(:retrieve_value) do |plugin_path|
				{}
			end

			expected_config = {}
			expect(output).to eq expected_config
		end
	end
end
