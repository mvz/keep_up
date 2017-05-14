# frozen_string_literal: true

require 'spec_helper'

describe KeepUp::Bundle do
  let(:definition_builder) { instance_double KeepUp::BundlerDefinitionBuilder }
  let(:runner) { class_double Kernel }
  let(:bundle) do
    described_class.new definition_builder: definition_builder, runner: runner
  end

  describe '#dependencies' do
    let(:outdated_result) do
      "\n" \
        "foo (newest 0.1.0, installed 0.0.5)\n" \
        "bar (newest 0.2.1, installed 0.1.5, requested ~> 0.1.2)\n"
    end
    let(:expected_dependencies) do
      [
        KeepUp::Dependency.new(name: 'foo', locked_version: '0.0.5',
                               requirement_list: []),
        KeepUp::Dependency.new(name: 'bar', locked_version: '0.1.5',
                               requirement_list: ['~> 0.1.2'])
      ]
    end

    before do
      allow(runner).to receive(:`).and_return(outdated_result)
    end

    it 'runs bundle outdated with parseable results' do
      bundle.dependencies
      expect(runner).to have_received(:`).with('bundle outdated --parseable')
    end

    it 'returns the correct set of dependencies' do
      result = bundle.dependencies
      expect(result).to match_array expected_dependencies
    end
  end
end
