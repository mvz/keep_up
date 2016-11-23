require 'spec_helper'

describe KeepUp::GemspecFilter do
  describe '.apply' do
    let(:dependency) { double('dep', name: 'foo', version: '1.2.0') }

    it 'works with old-stype dependency specifications' do
      contents = "spec.add_dependency 'foo', '1.1.0'"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "spec.add_dependency 'foo', '1.2.0'"
    end

    it 'works with new-style runtime dependency specifications' do
      contents = "spec.add_runtime_dependency 'foo', '1.1.0'"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "spec.add_runtime_dependency 'foo', '1.2.0'"
    end

    it 'works with brackets' do
      contents = "spec.add_runtime_dependency('foo', '1.1.0')"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "spec.add_runtime_dependency('foo', '1.2.0')"
    end

    it 'works with %q-style delimiters' do
      contents = "spec.add_runtime_dependency %q<foo>, '1.1.0'"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "spec.add_runtime_dependency %q<foo>, '1.2.0'"
    end

    it 'works with single-element dependency lists' do
      contents = "spec.add_runtime_dependency 'foo', ['= 1.1.0']"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "spec.add_runtime_dependency 'foo', ['= 1.2.0']"
    end

    it 'keeps line endings intact' do
      contents = "spec.add_runtime_dependency 'foo', '1.1.0'\n"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "spec.add_runtime_dependency 'foo', '1.2.0'\n"
    end

    it 'keeps indenting intact' do
      contents = "  spec.add_runtime_dependency 'foo', '1.1.0'"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "  spec.add_runtime_dependency 'foo', '1.2.0'"
    end

    it 'keeps squiggly version matchers intact' do
      contents = "  spec.add_runtime_dependency 'foo', '~> 1.1.0'"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "  spec.add_runtime_dependency 'foo', '~> 1.2.0'"
    end

    it 'keeps line endings intact' do
      contents = "spec.add_runtime_dependency 'foo', '1.1.0'\n"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "spec.add_runtime_dependency 'foo', '1.2.0'\n"
    end
  end
end

