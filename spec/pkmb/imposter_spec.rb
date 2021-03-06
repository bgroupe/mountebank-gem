require 'spec_helper'

RSpec.describe PkMb::Imposter do
  before:each do
    reset_mountebank
  end

  let(:port) { 4545 }
  let(:protocol) { PkMb::Imposter::PROTOCOL_HTTP }

  shared_examples 'blank imposter' do
    it 'valid imposter' do
      expect(imposter).to be_a PkMb::Imposter
      expect(imposter.port).to eq port
      expect(imposter.protocol).to eq protocol
      expect(imposter.name).to eq "imposter_#{port}"
      expect(imposter.stubs).to be_empty
      expect(imposter.requests).to be_empty
      expect(imposter.mode).to be_nil
    end
  end

  shared_examples 'persists imposter' do
    it 'persist to server' do
      imposter
      expect(PkMb.imposters).to_not be_empty
    end
  end

  describe '.build' do
    let(:imposter) { PkMb::Imposter.build(port, protocol) }

    it_should_behave_like 'blank imposter'
  end

  describe '.create' do
    context 'new imposter' do
      let(:imposter) { PkMb::Imposter.create(port, protocol) }

      it_should_behave_like 'blank imposter'
      it_should_behave_like 'persists imposter'
    end

    context 'assumes 2nd argument to be `http`' do
      let(:imposter) { PkMb::Imposter.create(port) }

      it_should_behave_like 'blank imposter'
      it_should_behave_like 'persists imposter'
    end

    context 'other creation options' do
      let(:imposter) { PkMb::Imposter.create(port, protocol, name:'meow_server') }

      it 'uses a different name' do
        expect(imposter.name).to eq 'meow_server'
      end
    end

    context 'invalid arguments' do
      it 'raises invalid port' do
        expect{ PkMb::Imposter.create('abcd') }.to raise_error 'Invalid port number'
      end

      it 'raises invalid protocol' do
        expect{ PkMb::Imposter.create(port, 'seattle') }.to raise_error 'Invalid protocol'
      end
    end

    context 'creates stub response' do
      let(:responses) { [
                          {is: {statusCode: 200, body:"ohai"}}
                        ]
                        }
      let(:predicates) { [] }
      let(:stubs) { [
                      PkMb::Stub.create(responses, predicates)
                    ]
                    }
      let!(:imposter) { PkMb::Imposter.create(port, protocol, stubs:stubs) }

      it 'is valid' do
        expect(test_url('http://127.0.0.1:4545')).to eq 'ohai'
        expect(imposter.reload.requests).to_not be_empty
        expect(imposter.stubs.first).to be_a PkMb::Stub
      end

      context 'with predicates' do
        let(:response_body) { "Its a real test" }
        let(:responses) { [
                            {is: {statusCode: 200, body:response_body}}
                          ]
                          }
        let(:predicates) { [
                             {equals: {path:'/test'}}
                           ]
                           }

        it 'is valid' do
          expect(test_url('http://127.0.0.1:4545/test')).to eq response_body
        end
      end
    end
  end

  describe '.get' do
    before do
      PkMb::Imposter.create(port)
    end

    context 'valid imposter' do
      let(:imposter) { PkMb::Imposter.find(port) }

      it_should_behave_like 'blank imposter'
      it_should_behave_like 'persists imposter'
    end

    context 'unknown imposter' do
      it 'returns false' do
        expect(PkMb::Imposter.find(4546)).to_not be
      end
    end
  end

  describe '.delete' do
    before do
      PkMb::Imposter.create(port)
    end

    context 'has imposter' do
      it 'returns true' do
        expect(PkMb::Imposter.delete(port)).to be
      end
    end

    context 'no imposter' do
      it 'returns false' do
        expect(PkMb::Imposter.delete(4546)).to_not be
      end
    end
  end

  describe '#reload' do
    before do
      PkMb::Imposter.create(port)
    end

    let!(:imposter) { PkMb::Imposter.find(port) }

    context 'no change' do
      it 'returns imposter' do
        expect(imposter.reload).to be_a PkMb::Imposter
      end

      it_should_behave_like 'blank imposter'
      it_should_behave_like 'persists imposter'
    end

    context 'has requests' do
      it 'returns imposter with requests' do
        test_url('http://127.0.0.1:4545')
        expect(imposter.reload.requests).to_not be_empty
      end
    end
  end

  describe '#add_stub' do
    let(:imposter) { PkMb::Imposter.build(port, protocol) }

    context 'with response' do
      before do
        response = PkMb::Stub::HttpResponse.create(200, {}, 'ohai you')
        imposter.add_stub(response)
      end

      it 'adds new stub' do
        expect(imposter.to_json).to eq("{\"port\":#{port},\"protocol\":\"#{protocol}\",\"name\":\"imposter_#{port}\",\"stubs\":[{\"responses\":[{\"is\":{\"statusCode\":200,\"body\":\"ohai you\"}}]}]}")
      end

      it 'is valid imposter' do
        imposter.save!
        expect(test_url('http://127.0.0.1:4545')).to eq('ohai you')
      end
    end

    context 'with predicate' do
      before do
        response = PkMb::Stub::HttpResponse.create(200, {}, 'ohai test2')
        data = {equals: {path:'/test2'}}
        predicate = PkMb::Stub::Predicate.new(data)
        imposter.add_stub(response, predicate)
      end

      it 'is valid imposter' do
        imposter.save!
        expect(test_url('http://127.0.0.1:4545/test2')).to eq('ohai test2')
      end
    end

    context "with array of responses" do
      before do
        response1 = PkMb::Stub::HttpResponse.create(200, {}, 'hello mother')
        response2 = PkMb::Stub::HttpResponse.create(200, {}, 'hello father')
        data = {equals: {path:'/test3'}}
        predicate = PkMb::Stub::Predicate.new(data)
        imposter.add_stub([response1, response2], predicate)
        imposter.save!
      end

      it 'should save stub in memory with 2 responses' do
        expect(imposter.stubs.first.responses.length).to eq(2)
      end

      it 'should save stub to server with 2 responses' do
        stub = PkMb::Imposter.get_imposter_config(port)[:stubs].first
        expect(stub[:responses].length).to eq(2)
      end

      it 'is a valid imposter with 2 responses' do
        expect(test_url('http://127.0.0.1:4545/test3')).to eq('hello mother')
        expect(test_url('http://127.0.0.1:4545/test3')).to eq('hello father')
      end
    end

    context "with array of predicates" do
      before do
        response1 = PkMb::Stub::HttpResponse.create(200, {}, 'hello mother')
        data1 = {equals: {path:'/test3'}}
        data2 = {equals: {method:'GET'}}
        predicate1 = PkMb::Stub::Predicate.new(data1)
        predicate2 = PkMb::Stub::Predicate.new(data2)
        imposter.add_stub(response1, [predicate1, predicate2])
        imposter.save!
      end

      it 'should save stub in memory with 2 predicates' do
        expect(imposter.stubs.first.predicates.length).to eq(2)
      end

      it 'should save stub to server with 2 predicates' do
        stub = PkMb::Imposter.get_imposter_config(port)[:stubs].first
        expect(stub[:predicates].length).to eq(2)
      end

      it 'is a valid imposter' do
        expect(test_url('http://127.0.0.1:4545/test3')).to eq('hello mother')
      end

    end

  end



  describe '#replayable_data' do
    let(:imposter) { PkMb::Imposter.build(port, protocol) }

    it 'returns valid data' do
      expect(imposter.replayable_data).to eq({port:port, protocol:protocol, name:"imposter_#{port}"})
    end
  end
end
