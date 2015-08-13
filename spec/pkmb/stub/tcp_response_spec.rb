require 'spec_helper'

RSpec.describe PkMb::Stub::TcpResponse do
  let(:data) { 'blah' }
  let!(:response) { PkMb::Stub::TcpResponse.create(data) }

  describe '.create' do
    it 'returns response object' do
      expect(response).to be_a PkMb::Stub::TcpResponse
      expect(response.to_json).to eq '{"is":{"data":"blah"}}'
    end
  end
end
