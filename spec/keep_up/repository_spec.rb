# frozen_string_literal: true

require 'spec_helper'

describe KeepUp::Repository do
  describe '#updated_dependency_for' do
    let(:index) { instance_double(KeepUp::GemIndex) }
    let(:repository) { described_class.new(index: index) }
    let(:locked_version) { Gem::Version.new locked_version_string }
    let(:locked_dependency) { instance_double(KeepUp::Dependency) }
    let(:version_strings) { ['0.9.0', '1.0.0', '1.1.0'] }
    let(:versions) { version_strings.map { |it| Gem::Version.new it } }
    let(:specs) { versions.map { |it| instance_double(Gem::Specification, version: it) } }

    before do
      allow(locked_dependency).to receive(:locked_version).and_return locked_version
      allow(index).
        to receive(:search).with(locked_dependency).
        and_return specs
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

    context 'when the current locked version higher than the latest' do
      let(:locked_version_string) { '1.2.0' }

      it 'returns nil' do
        expect(repository.updated_dependency_for(locked_dependency)).to be_nil
      end
    end

    context 'when pre-releases are also available' do
      let(:version_strings) { ['1.0.0', '1.1.0', '1.2.0.pre.1', '1.2.0.pre.2'] }

      context 'when the current version is a not a pre-release' do
        let(:locked_version_string) { '1.0.0' }

        it 'returns the latest regular version found on the remote index' do
          result = repository.updated_dependency_for(locked_dependency)
          expect(result.version.to_s).to eq '1.1.0'
        end
      end

      context 'when a current pre-release can be updated to a newer regular release' do
        let(:locked_version_string) { '1.0.0.pre.1' }

        it 'returns the latest regular version found on the remote index' do
          result = repository.updated_dependency_for(locked_dependency)
          expect(result.version.to_s).to eq '1.1.0'
        end
      end

      context 'when a current pre-release can only be updated to a newer pre-release' do
        let(:locked_version_string) { '1.2.0.pre.1' }

        it 'returns the latest pre-release version found on the remote index' do
          result = repository.updated_dependency_for(locked_dependency)
          expect(result.version.to_s).to eq '1.2.0.pre.2'
        end
      end
    end
  end
end
