require 'spec_helper'

describe KeepUp::Repository do
  describe '#updated_dependency_for' do
    let(:remote_index) { double('remote index') }
    let(:repository) { described_class.new(remote_index: remote_index) }
    let(:locked_dependency) do
      double('locked dependency',
             version: version,
             locked_version: locked_version)
    end

    before do
      allow(remote_index).
        to receive(:search).with(locked_dependency).
        and_return [
          double('dep09', version: '0.9.0'),
          double('dep10', version: '1.0.0'),
          double('dep11', version: '1.1.0')
        ]
    end

    context 'when the current version is not the latest' do
      let(:version) { '~> 1.0' }
      let(:locked_version) { '1.0.0' }

      it 'returns the latest version found on the remote index' do
        result = repository.updated_dependency_for(locked_dependency)
        expect(result.version).to eq '1.1.0'
      end
    end

    context 'when the current locked version is the latest' do
      let(:version) { '~> 1.0' }
      let(:locked_version) { '1.1.0' }

      it 'returns nil' do
        expect(repository.updated_dependency_for(locked_dependency)).to be_nil
      end
    end

    context 'when the current locked version higher than the latest' do
      let(:version) { '~> 1.0' }
      let(:locked_version) { '1.2.0' }

      it 'returns nil' do
        expect(repository.updated_dependency_for(locked_dependency)).to be_nil
      end
    end
  end
end
