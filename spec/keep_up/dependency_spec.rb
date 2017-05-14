require 'spec_helper'

describe KeepUp::Dependency do
  describe '#locked_version' do
    it 'normalizes the version to a Gem::Version' do
      dep = KeepUp::Dependency.new(name: 'foo',
                                   locked_version: '0.5.2',
                                   requirement_list: [])
      expect(dep.locked_version).to eq Gem::Version.new '0.5.2'
    end
  end
end
