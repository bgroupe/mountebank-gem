require 'spec_helper'

RSpec.describe PkMb do
  before:each do
    reset_mountebank
  end

  describe '.reset' do
    it 'returns' do
      expect(PkMb.reset).to be
    end
  end

  describe '.imposters' do
    context 'no imposters' do
      it 'blank' do
        expect(PkMb.imposters).to be_empty
      end
    end

    context 'has imposters' do
      before do
        PkMb::Imposter.create(4545)
      end

      it 'not empty' do
        expect(PkMb.imposters).to_not be_empty
      end

      it 'returns valid imposter' do
        expect(PkMb.imposters.first).to be_a PkMb::Imposter
      end
    end
  end
end
