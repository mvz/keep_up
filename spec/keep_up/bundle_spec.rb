# frozen_string_literal: true

require "spec_helper"

describe KeepUp::Bundle, type: :aruba do
  let(:runner) { KeepUp::Runner }
  let(:bundle) do
    described_class.new runner: runner, local: false
  end

  before do
    write_local_gemfile("gemspec")
    write_gemspec("qux", "0.1.0", { "foo" => nil,
                                    "bar" => "~> 0.1.2",
                                    "baz" => ["> 0.1.2", "<= 0.3.0"] })
    write_gem("foo", "0.0.5")
    write_gem("bar", "0.1.5")
    write_gem("baz", "0.2.8")

    generate_local_gem_index

    in_current_directory { Bundler.with_unbundled_env { `bundle lock` } }

    write_gem("foo", "0.1.0")
    write_gem("bar", "0.2.1")
    write_gem("baz", "0.3.4")

    generate_local_gem_index

    in_current_directory do
      Bundler.with_unbundled_env { `bundle config set path 'vendor'` }
    end
  end

  describe "#outdated_dependencies" do
    let(:expected_dependencies) do
      [
        KeepUp::Dependency.new(
          name: "foo",
          locked_version: "0.0.5",
          newest_version: "0.1.0",
          requirement_list: [">= 0"]
        ),
        KeepUp::Dependency.new(
          name: "bar",
          locked_version: "0.1.5",
          newest_version: "0.2.1",
          requirement_list: ["~> 0.1.2"]
        ),
        KeepUp::Dependency.new(
          name: "baz",
          locked_version: "0.2.8",
          newest_version: "0.3.4",
          requirement_list: ["> 0.1.2", "<= 0.3.0"]
        )
      ]
    end

    it "returns the correct set of dependencies" do
      result = in_current_directory do
        Bundler.with_unbundled_env { bundle.outdated_dependencies }
      end
      expect(result).to match_array expected_dependencies
    end
  end

  describe "#update_dependency" do
    let(:dependency) do
      KeepUp::Dependency.new(
        name: "bar",
        locked_version: "0.1.5",
        newest_version: "0.2.1",
        requirement_list: ["~> 0.1.2"]
      )
    end

    it "returns the correct lockfile update" do
      _, lock_result = in_current_directory do
        Bundler.with_unbundled_env { bundle.update_dependency(dependency) }
      end
      aggregate_failures do
        expect(lock_result.name).to eq "bar"
        expect(lock_result.version).to eq Gem::Version.new("0.2.1")
      end
    end

    it "returns the correct specfile update" do
      spec_result, = in_current_directory do
        Bundler.with_unbundled_env { bundle.update_dependency(dependency) }
      end
      aggregate_failures do
        expect(spec_result.name).to eq "bar"
        expect(spec_result.version).to eq Gem::Version.new("0.2.1")
      end
    end
  end
end
