require 'spec_helper'

RSpec.describe PkMb::Stub do
  let(:responses) { [] }
  let(:predicates) { [] }
  let(:stub) { PkMb::Stub.create(responses, predicates) }

  describe '#initialize' do
    it 'creates a new object' do
      expect(stub).to be_a PkMb::Stub
      expect(stub.responses).to eq []
      expect(stub.predicates).to eq []
      expect(stub.to_json).to eq '{}'
    end
  end

  context 'has responses' do
    let(:responses) { [
        {
          is: {statusCode: 200, body:"ohai"}
        }
      ]
    }

    it 'is not empty' do
      expect(stub.responses).to_not be_empty
    end

    it 'is a response' do
      expect(stub.responses.first).to be_a PkMb::Stub::Response
      expect(stub.responses.first.is[:statusCode]).to eq 200
    end

    it 'renders correct JSON' do
      expect(stub.to_json).to eq '{"responses":[{"is":{"statusCode":200,"body":"ohai"}}]}'
    end
  end

  context 'has predicates' do
    let(:predicates) { [
        {
          equals: {path:'/test'}
        }
      ]
    }

    it 'is not empty' do
      expect(stub.predicates).to_not be_empty
    end

    it 'is a predicate' do
      expect(stub.predicates.first).to be_a PkMb::Stub::Predicate
      expect(stub.predicates.first.equals[:path]).to eq('/test')
    end

    it 'renders correct JSON' do
      expect(stub.to_json).to eq '{"predicates":[{"equals":{"path":"/test"}}]}'
    end
  end
end

