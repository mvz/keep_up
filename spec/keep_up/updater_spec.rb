require 'spec_helper'

describe KeepUp::Updater do
  describe '#run' do
    let(:dependency) { double('dependency') }
    let(:dependencies) { [dependency] }
    let(:bundle) { double('bundle', direct_dependencies: dependencies) }
    let(:repository) { double('repository') }
    let(:version_control) { double('version_control') }

    let(:updater) do
      described_class.new(bundle: bundle,
                          repository: repository,
                          version_control: version_control)
    end

    before do
      allow(version_control).to receive(:commit_changes)
      allow(version_control).to receive(:revert_changes)
    end

    context 'when an update is available' do
      let(:updated_dependency) { double('updated_dependency') }

      before do
        allow(repository).
          to receive(:updated_dependency_for).
          with(dependency).
          and_return updated_dependency
      end

      context 'when applying the update succeeds' do
        before do
          allow(bundle).to receive(:apply_updated_dependency).and_return true
        end

        it 'lets the bundle update to the new dependency' do
          updater.run
          expect(bundle).
            to have_received(:apply_updated_dependency).
            with updated_dependency
        end

        it 'commits the changes' do
          updater.run
          expect(version_control).
            to have_received(:commit_changes).
            with updated_dependency
        end
      end

      context 'when applying the update fails' do
        before do
          allow(bundle).to receive(:apply_updated_dependency).and_return false
        end

        it 'lets the bundle try to update to the new dependency' do
          updater.run
          expect(bundle).
            to have_received(:apply_updated_dependency).
            with updated_dependency
        end

        it 'does not commit the changes' do
          updater.run
          expect(version_control).not_to have_received(:commit_changes)
        end

        it 'reverts the changes' do
          updater.run
          expect(version_control).to have_received(:revert_changes)
        end
      end
    end

    context 'when a filter is provided' do
      let(:updated_dependency) { double('updated_dependency') }
      let(:filter) { double('filter') }
      let(:updater) do
        described_class.new(bundle: bundle,
                            repository: repository,
                            version_control: version_control,
                            filter: filter)
      end

      before do
        allow(repository).
          to receive(:updated_dependency_for).
          with(dependency).
          and_return updated_dependency
        allow(bundle).to receive(:apply_updated_dependency).and_return true
      end

      context 'when the updateable dependency is filtered out' do
        before do
          allow(filter).to receive(:call).with(dependency).and_return false
          updater.run
        end

        it 'does not let the bundle update to the new dependency' do
          expect(bundle).not_to have_received(:apply_updated_dependency)
        end

        it 'does not commit anything' do
          expect(version_control).not_to have_received(:commit_changes)
        end

        it 'does not revert anything' do
          expect(version_control).not_to have_received(:revert_changes)
        end
      end

      context 'when the updateable dependency is not filtered out' do
        before do
          allow(filter).to receive(:call).with(dependency).and_return true
          updater.run
        end

        it 'lets the bundle update to the new dependency' do
          expect(bundle).
            to have_received(:apply_updated_dependency).
            with updated_dependency
        end

        it 'commits the changes' do
          expect(version_control).
            to have_received(:commit_changes).
            with updated_dependency
        end
      end
    end

    context 'when no update is available' do
      before do
        allow(repository).
          to receive(:updated_dependency_for).
          with(dependency).
          and_return nil
      end

      it 'does not let the bundle update anything' do
        expect(bundle).not_to receive(:apply_updated_dependency)
        updater.run
      end
    end

    context 'when several dependencies are present with an available update' do
      let(:other_dependency) { double('other dependency') }
      let(:dependencies) { [dependency, other_dependency] }
      let(:updated_dependency) { double('updated dependency') }
      let(:updated_other_dependency) { double('updated other dependency') }

      before do
        allow(repository).
          to receive(:updated_dependency_for).with(dependency).
          and_return updated_dependency
        allow(repository).
          to receive(:updated_dependency_for).with(other_dependency).
          and_return updated_other_dependency
        allow(bundle).to receive(:apply_updated_dependency).and_return true
      end

      it 'applies each update' do
        updater.run
        expect(bundle).
          to have_received(:apply_updated_dependency).
          with(updated_dependency)
        expect(bundle).
          to have_received(:apply_updated_dependency).
          with(updated_other_dependency)
      end
    end

    context 'when two dependencies result in the same update' do
      let(:other_dependency) { double('other dependency') }
      let(:dependencies) { [dependency, other_dependency] }
      let(:updated_dependency) { double('updated dependency') }

      before do
        allow(repository).
          to receive(:updated_dependency_for).with(dependency).
          and_return updated_dependency
        allow(repository).
          to receive(:updated_dependency_for).with(other_dependency).
          and_return updated_dependency
        allow(bundle).to receive(:apply_updated_dependency).and_return true
      end

      it 'applies the update only once' do
        updater.run
        expect(bundle).
          to have_received(:apply_updated_dependency).
          with(updated_dependency).once
      end
    end
  end
end
