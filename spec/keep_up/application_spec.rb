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
    let(:local) { false }

    before do
      allow(runner).to receive(:run).with('git status -s').and_return ''
      allow(runner).to receive(:run).with('bundle outdated --parseable').and_return ''
      allow(runner).to receive(:run2).with('bundle check').and_return ['', 0]
    end

    it 'runs' do
      application.run
    end
  end
end
