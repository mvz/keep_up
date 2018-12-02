# frozen_string_literal: true

require 'spec_helper'

describe KeepUp::Repository do
  describe '#updated_dependency_for' do
    let(:index) { instance_double(KeepUp::GemIndex) }
    let(:repository) { described_class.new(index: index) }

    let(:version_string) { '1.1.0' }
    let(:newest_version) { Gem::Version.new version_string }
    let(:locked_version) { Gem::Version.new locked_version_string }
    let(:locked_dependency) do
      KeepUp::Dependency.new(name: 'foo', requirement_list: [],
                             newest_version: newest_version, locked_version: locked_version)
    end

    context 'when the current version is not the latest' do
      let(:locked_version_string) { '1.0.0' }

      it 'returns the latest version found on the remote index' do
        result = repository.updated_dependency_for(locked_dependency)
        expect(result.version.to_s).to eq '1.1.0'
      end
    end

    context 'when the current locked version is the latest' do
      let(:locked_version_string) { '1.1.0' }

      it 'returns nil' do
        expect(repository.updated_dependency_for(locked_dependency)).to be_nil
      end
    end

    context 'when the current locked version is newer than the latest' do
      let(:locked_version_string) { '1.2.0' }

      it 'returns nil' do
        expect(repository.updated_dependency_for(locked_dependency)).to be_nil
      end
    end
  end
end
