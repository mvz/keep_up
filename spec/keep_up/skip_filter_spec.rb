# frozen_string_literal: true

require 'spec_helper'

describe KeepUp::SkipFilter do
  describe '#call' do
    let(:accepted_dependency) { instance_double(KeepUp::Dependency, name: 'foo') }
    let(:rejected_dependency) { instance_double(KeepUp::Dependency, name: 'bar') }

    let(:filter) do
      described_class.new(['bar'])
    end

    it 'rejects dependencies that are on the skip list' do
      expect(filter.call(rejected_dependency)).to be_falsey
    end

    it 'accepts dependencies that are not on the skip list' do
      expect(filter.call(accepted_dependency)).to be_truthy
    end
  end
end
