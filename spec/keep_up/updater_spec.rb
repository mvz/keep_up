require 'spec_helper'

describe KeepUp::Updater do
  describe '#run' do
    let(:dependency) { double('dependency') }
    let(:gemfile) { double('gemfile', direct_dependencies: [dependency]) }
    let(:repository) { double('repository') }
    let(:version_control) { double('version_control') }

    let(:updater) do
      described_class.new(gemfile: gemfile, repository: repository, version_control: version_control)
    end

    before do
      allow(version_control).to receive(:commit_changes)
    end

    context 'when an update is available' do
      let(:updated_dependency) { double('updated_dependency') }

      before do
        allow(repository).
          to receive(:updated_dependency_for).
          with(dependency).
          and_return updated_dependency
        allow(gemfile).to receive(:apply_updated_dependency)
      end

      it 'lets the gemfile update to the new dependency' do
        updater.run
        expect(gemfile).to have_received(:apply_updated_dependency).with updated_dependency
      end

      it 'commits the changes' do
        updater.run
        expect(version_control).to have_received(:commit_changes).with updated_dependency
      end
    end

    context 'when no update is available' do
      before do
        allow(repository).
          to receive(:updated_dependency_for).
          with(dependency).
          and_return nil
      end

      it 'does not let the gemfile update anything' do
        expect(gemfile).not_to receive(:apply_updated_dependency)
        updater.run
      end
    end
  end
end
