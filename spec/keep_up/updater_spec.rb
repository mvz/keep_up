# frozen_string_literal: true

require 'spec_helper'

describe KeepUp::Updater do
  describe '#run' do
    let(:bundle) { instance_double(KeepUp::Bundle, dependencies: dependencies) }
    let(:version_control) { instance_double(KeepUp::VersionControl) }

    let(:dependency) do
      KeepUp::Dependency.new(name: 'dependency',
                             requirement_list: [],
                             locked_version: '1.1.0',
                             newest_version: updated_dependency_version)
    end
    let(:updated_dependency) do
      Gem::Specification.new('dependency', updated_dependency_version)
    end

    let(:update_result) do
      instance_double(Gem::Specification, 'update result', version: 'foo')
    end

    let(:updater) do
      described_class.new(bundle: bundle,
                          version_control: version_control,
                          out: StringIO.new)
    end

    before do
      allow(version_control).to receive(:commit_changes)
      allow(version_control).to receive(:revert_changes)
      allow(bundle).to receive(:update_gemfile_contents)
      allow(bundle).to receive(:update_gemspec_contents)
      allow(bundle).to receive(:update_lockfile).and_return update_result
    end

    context 'when an update is available' do
      let(:updated_dependency_version) { '1.2.0' }
      let(:dependencies) { [dependency] }

      context 'when applying the update succeeds' do
        it 'updates the gemfile' do
          updater.run
          expect(bundle).to have_received(:update_gemfile_contents).with(updated_dependency)
        end

        it 'updates the gemspec' do
          updater.run
          expect(bundle).to have_received(:update_gemspec_contents).with(updated_dependency)
        end

        it 'lets the bundle update to the new dependency' do
          updater.run
          expect(bundle).to have_received(:update_lockfile).with(updated_dependency)
        end

        it 'commits the changes' do
          updater.run
          expect(version_control).
            to have_received(:commit_changes).
            with update_result
        end
      end

      context 'when applying the update fails' do
        before do
          allow(bundle).to receive(:update_lockfile).and_return false
        end

        it 'lets the bundle try to update to the new dependency' do
          updater.run
          expect(bundle).
            to have_received(:update_lockfile).
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

    context 'when an update is available and a filter is provided' do
      let(:updated_dependency_version) { '1.2.0' }
      let(:dependencies) { [dependency] }
      let(:filter) { instance_double(KeepUp::SkipFilter) }
      let(:updater) do
        described_class.new(bundle: bundle,
                            version_control: version_control,
                            out: StringIO.new,
                            filter: filter)
      end

      before do
        allow(bundle).to receive(:update_lockfile).and_return update_result
      end

      context 'when the updateable dependency is filtered out' do
        before do
          allow(filter).to receive(:call).with(dependency).and_return false
          updater.run
        end

        it 'does not let the bundle update to the new dependency' do
          expect(bundle).not_to have_received(:update_lockfile)
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
            to have_received(:update_lockfile).
            with updated_dependency
        end

        it 'commits the changes' do
          expect(version_control).
            to have_received(:commit_changes).
            with update_result
        end
      end
    end

    context 'when the dependency is already at the latest version' do
      let(:updated_dependency_version) { '1.1.0' }
      let(:dependencies) { [dependency] }

      it 'does not let the bundle update anything' do
        updater.run
        expect(bundle).not_to have_received(:update_lockfile)
      end
    end

    context 'when the dependency is ahead of the latest version' do
      let(:updated_dependency_version) { '1.0.0' }
      let(:dependencies) { [dependency] }

      it 'does not let the bundle update anything' do
        updater.run
        expect(bundle).not_to have_received(:update_lockfile)
      end
    end

    context 'when several dependencies are present with an available update' do
      let(:other_dependency) do
        KeepUp::Dependency.new(name: 'another',
                               requirement_list: [],
                               locked_version: '0.5.2',
                               newest_version: '0.6.9')
      end
      let(:updated_dependency_version) { '1.2.0' }
      let(:dependencies) { [dependency, other_dependency] }

      it 'applies each update' do
        updater.run
        expect(bundle).to have_received(:update_lockfile).twice
      end
    end

    context 'when two dependencies result in the same update' do
      let(:updated_dependency_version) { '1.2.0' }
      let(:dependencies) { [dependency, dependency] }

      it 'applies the update only once' do
        updater.run
        expect(bundle).
          to have_received(:update_lockfile).
          with(updated_dependency).once
      end
    end
  end
end
