require 'spec_helper'

describe KeepUp::Repository do
  describe '#updated_dependency_for' do
    let(:remote_index) { double('remote index') }
    let(:repository) { described_class.new(remote_index: remote_index) }
    let(:locked_dependency) { double('locked dependency', version: '1.0.0', locked_version: '1.0.0') }

    before do
      allow(remote_index).
        to receive(:search).with(locked_dependency).
        and_return [
          double('dep', version: '0.9.0'),
          double('dep', version: '1.0.0'),
          double('dep', version: '1.1.0') ]
    end

    it 'returns the latest version found on the remote index' do
      result = repository.updated_dependency_for(locked_dependency)
      expect(result.version).to eq '1.1.0'
    end
  end
end
