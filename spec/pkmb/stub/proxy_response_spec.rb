require 'spec_helper'

RSpec.describe PkMb::Stub::ProxyResponse do
  let(:to) { 'http://example.com' }
  let(:mode) { PkMb::Stub::ProxyResponse::PROXY_MODE_ONCE }
  let(:predicateGenerators) { [
      { matches: {
          method:true,
          path:true,
          query:true
        }
      }
    ]
  }
  let!(:response) { PkMb::Stub::ProxyResponse.create(to, mode, predicateGenerators) }

  describe '.create' do
    it 'returns response object' do
      expect(response).to be_a PkMb::Stub::ProxyResponse
      expect(response.to_json).to eq '{"proxy":{"to":"http://example.com","mode":"proxyOnce","predicateGenerators":[{"matches":{"method":true,"path":true,"query":true}}]}}'
    end
  end
end
