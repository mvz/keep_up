# frozen_string_literal: true

require "spec_helper"

describe KeepUp::Bundle do
  let(:runner) { class_double KeepUp::Runner }
  let(:bundle) do
    described_class.new runner: runner, local: false
  end

  describe "#outdated_dependencies" do
    let(:outdated_result) do
      "\n" \
        "foo (newest 0.1.0, installed 0.0.5)\n" \
        "bar (newest 0.2.1, installed 0.1.5, requested ~> 0.1.2)\n" \
        "baz (newest 1.2.1 f1e2d3c, installed 0.2.5 dbabdab)\n" \
        "qux (newest 0.3.4, installed 0.2.8, requested > 0.1.2, <= 0.3.0)\n"
    end
    let(:expected_dependencies) do
      [
        KeepUp::Dependency.new(
          name: "foo",
          locked_version: "0.0.5",
          newest_version: "0.1.0",
          requirement_list: nil
        ),
        KeepUp::Dependency.new(
          name: "bar",
          locked_version: "0.1.5",
          newest_version: "0.2.1",
          requirement_list: ["~> 0.1.2"]
        ),
        KeepUp::Dependency.new(
          name: "baz",
          locked_version: "0.2.5",
          newest_version: "1.2.1",
          requirement_list: nil
        ),
        KeepUp::Dependency.new(
          name: "qux",
          locked_version: "0.2.8",
          newest_version: "0.3.4",
          requirement_list: ["> 0.1.2", "<= 0.3.0"]
        )
      ]
    end

    before do
      allow(runner).to receive(:run).and_return(outdated_result)
    end

    it "runs bundle outdated with parseable results" do
      bundle.outdated_dependencies
      expect(runner).to have_received(:run).with("bundle outdated --parseable")
    end

    it "returns the correct set of dependencies" do
      result = bundle.outdated_dependencies
      expect(result).to eq expected_dependencies
    end
  end

  describe "#update_dependency" do
    let(:dependency) do
      KeepUp::Dependency.new(name: "bar", locked_version: "1.0.0", newest_version: "2.0.0",
                             requirement_list: [])
    end

    before do
      allow(runner).to receive(:run).and_return(run_result)
    end

    context "when bundler shows the old version" do
      let(:run_result) do
        <<~OUTPUT
          Using foo 1.0.1
          Using bar 2.0.0 (was 1.0.0)
          Using baz 3.2.1
        OUTPUT
      end

      it "detects the lockfile update by comparing with the old version" do
        _, lock_result = bundle.update_dependency(dependency)
        aggregate_failures do
          expect(lock_result.name).to eq "bar"
          expect(lock_result.version).to eq Gem::Version.new("2.0.0")
        end
      end
    end

    context "when bundler does not show the old version" do
      let(:run_result) do
        <<~OUTPUT
          Using foo 1.0.1
          Using bar 2.0.0
          Using baz 3.2.1
        OUTPUT
      end

      it "detects the lockfile update by comparing with the old version" do
        _, lock_result = bundle.update_dependency(dependency)
        aggregate_failures do
          expect(lock_result.name).to eq "bar"
          expect(lock_result.version).to eq Gem::Version.new("2.0.0")
        end
      end
    end
  end
end
