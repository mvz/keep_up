require 'spec_helper'

describe KeepUp::Updater do
  describe '#run' do
    context 'when an update is available' do
      let(:dependency) { double('dependency') }
      let(:updated_dependency) { double('updated_dependency') }
      let(:gemfile) { double('gemfile', direct_dependencies: [dependency]) }
      let(:repository) { double('repository') }

      let(:updater) { described_class.new(gemfile: gemfile, repository: repository) }

      before do
        allow(repository).
          to receive(:updated_dependency_for).
          with(dependency).
          and_return updated_dependency
      end

      it 'lets the gemfile update to the new dependency' do
        expect(gemfile).to receive(:apply_updated_dependency).with(updated_dependency)
        updater.run
      end
    end
  end
end
