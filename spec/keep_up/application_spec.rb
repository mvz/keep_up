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
    let(:outdated_result) { "\nfoo (newest 0.1.0, installed 0.0.5)\n" }
    let(:update_result) { "Using foo 0.1.0 (was 0.0.5)\n" }

    before do
      allow(runner).to receive(:run).with('git status -s').and_return ''
      allow(runner).to receive(:run2).with('bundle check').and_return ['', 0]

      allow(runner).to receive(:run).
        with(a_string_matching(/bundle outdated/)).once.and_return outdated_result
      allow(runner).to receive(:run).
        with(a_string_matching(/bundle update/)).once.and_return update_result
      allow(runner).to receive(:run).
        with(a_string_matching(/git commit/)).and_return ''
    end

    context 'when not requested to run locally' do
      let(:local) { false }

      it 'does not pass the --local option to bundle outdated' do
        application.run
        expect(runner).to have_received(:run).
          with('bundle outdated --parseable')
      end

      it 'does not pass the --local option to bundle update' do
        application.run
        expect(runner).to have_received(:run).
          with('bundle update --conservative foo')
      end
    end

    context 'when requested to run locally' do
      let(:local) { true }

      it 'passes the --local option to bundle outdated' do
        application.run
        expect(runner).to have_received(:run).
          with('bundle outdated --parseable --local')
      end

      it 'passes the --local option to bundle update' do
        application.run
        expect(runner).to have_received(:run).
          with('bundle update --local --conservative foo')
      end
    end
  end
end
