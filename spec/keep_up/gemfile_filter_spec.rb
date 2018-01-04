# frozen_string_literal: true

require 'spec_helper'

describe KeepUp::GemfileFilter do
  describe '.apply' do
    let(:dependency) { instance_double(Gem::Specification, name: 'foo', version: '1.2.0') }

    it 'keeps line endings intact' do
      contents = "gem 'foo', '1.1.0'\n"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "gem 'foo', '1.2.0'\n"
    end

    it 'keeps indenting intact' do
      contents = "  gem 'foo', '1.1.0'"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "  gem 'foo', '1.2.0'"
    end

    it 'keeps squiggly version matchers intact' do
      contents = "  gem 'foo', '~> 1.1.0'"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "  gem 'foo', '~> 1.2.0'"
    end

    it 'handles extra white space' do
      contents = "gem  'foo',  '1.1.0' "

      result = described_class.apply(contents, dependency)
      expect(result).to eq "gem  'foo',  '1.2.0' "
    end

    it 'handles tabs' do
      contents = "\tgem\t'foo',\t'1.1.0'\t"

      result = described_class.apply(contents, dependency)
      expect(result).to eq "\tgem\t'foo',\t'1.2.0'\t"
    end
  end
end
