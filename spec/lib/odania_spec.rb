describe Odania do

	describe 'odania' do
		let(:ips) { subject.ips }

		it 'retrieve ips' do
			expect(ips).not_to be_empty
		end
	end
end
