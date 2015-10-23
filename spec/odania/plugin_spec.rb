require 'spec_helper'

describe Odania::Plugin do
	subject { Odania::Plugin.new }

	describe 'plugins_config' do
		let(:output) { subject.plugins_config }

		it 'retrieves config' do
			allow(subject).to receive(:retrieve_value) do |plugin_path|
				{}
			end

			expected_config = {}
			expect(output).to eq expected_config
		end
	end
end
