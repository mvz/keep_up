# frozen_string_literal: true

require 'spec_helper'

describe KeepUp::Bundle do
  let(:runner) { class_double KeepUp::Runner }
  let(:bundle) do
    described_class.new runner: runner
  end

  describe '#dependencies' do
    let(:outdated_result) do
      "\n" \
        "foo (newest 0.1.0, installed 0.0.5)\n" \
        "bar (newest 0.2.1, installed 0.1.5, requested ~> 0.1.2)\n" \
        "baz (newest 1.2.1 f1e2d3c, installed 0.2.5 dbabdab)\n" \
        "qux (newest 0.3.4, installed 0.2.8, requested > 0.1.2, <= 0.3.0)\n"
    end
    let(:expected_dependencies) do
      [
        KeepUp::Dependency.new(name: 'foo',
                               locked_version: '0.0.5',
                               newest_version: '0.1.0',
                               requirement_list: nil),
        KeepUp::Dependency.new(name: 'bar',
                               locked_version: '0.1.5',
                               newest_version: '0.2.1',
                               requirement_list: ['~> 0.1.2']),
        KeepUp::Dependency.new(name: 'baz',
                               locked_version: '0.2.5',
                               newest_version: '1.2.1',
                               requirement_list: nil),
        KeepUp::Dependency.new(name: 'qux',
                               locked_version: '0.2.8',
                               newest_version: '0.3.4',
                               requirement_list: ['> 0.1.2', '<= 0.3.0'])
      ]
    end

    before do
      allow(runner).to receive(:run).and_return(outdated_result)
    end

    it 'runs bundle outdated with parseable results' do
      bundle.dependencies
      expect(runner).to have_received(:run).with('bundle outdated --parseable')
    end

    it 'returns the correct set of dependencies' do
      result = bundle.dependencies
      expect(result).to eq expected_dependencies
    end
  end
end
