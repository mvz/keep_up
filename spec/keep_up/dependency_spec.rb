# frozen_string_literal: true

require "spec_helper"

RSpec.describe KeepUp::Dependency do
  let(:dep) do
    described_class.new(
      name: "foo",
      locked_version: "0.5.2",
      newest_version: "0.6.8",
      requirement_list: []
    )
  end

  describe "#locked_version" do
    it "normalizes the version to a Gem::Version" do
      expect(dep.locked_version).to eq Gem::Version.new "0.5.2"
    end
  end

  describe "#newest_version" do
    it "normalizes the version to a Gem::Version" do
      expect(dep.newest_version).to eq Gem::Version.new "0.6.8"
    end
  end
end
