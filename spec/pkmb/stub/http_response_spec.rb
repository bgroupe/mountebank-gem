require 'spec_helper'

RSpec.describe PkMb::Stub::HttpResponse do
  let(:statusCode) { 200 }
  let(:headers) { {"Content-Type" => "application/json"} }
  let(:body) { {foo:"bar"}.to_json }
  let!(:response) { PkMb::Stub::HttpResponse.create(statusCode, headers, body) }

  describe '.create' do
    it 'returns response object' do
      expect(response).to be_a PkMb::Stub::HttpResponse
      expect(response.to_json).to eq '{"is":{"statusCode":200,"headers":{"Content-Type":"application/json"},"body":"{\"foo\":\"bar\"}"}}'
    end
  end
end
