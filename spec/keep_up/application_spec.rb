# frozen_string_literal: true

require 'spec_helper'

RSpec.describe KeepUp::Application do
  let(:runner) { class_double KeepUp::Runner }
  let(:application) do
    described_class.new(local: local,
                        test_command: nil,
                        skip: [],
                        runner: runner)
  end

  describe '#run' do
    before do
      allow(runner).to receive(:run).with('git status -s').and_return ''
      allow(runner).to receive(:run2).with('bundle check').and_return ['', 0]
      allow(runner).to receive(:run).
        with(a_string_matching(/bundle outdated/)).and_return ''
    end

    context 'when not requested to run locally' do
      let(:local) { false }

      it 'does not pass the --local option to bundle outdated' do
        application.run
        aggregate_failures do
          expect(runner).to have_received(:run).
            with('bundle outdated --parseable')
          expect(runner).not_to have_received(:run).
            with('bundle outdated --parseable --local')
        end
      end
    end

    context 'when requested to run locally' do
      let(:local) { true }

      it 'passes the --local option to bundle outdated' do
        application.run
        aggregate_failures do
          expect(runner).to have_received(:run).
            with('bundle outdated --parseable --local')
          expect(runner).not_to have_received(:run).
            with('bundle outdated --parseable')
        end
      end
    end
  end
end
