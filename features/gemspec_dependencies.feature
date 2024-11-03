Feature: Gemspec dependencies
  As a developer
  In order to keep my gem up to date
  I want to update dependencies in a gemspec

  Scenario: Updating a gemspec with fixed dependency versions
    Given the following remote gems:
      | name | version |
      | foo  | 1.0.0   |
      | foo  | 1.0.1   |
    And a Gemfile specifying:
      """
      gemspec
      """
    And a gemspec for "bar" depending on "foo" at version "1.0.0"
    And a Gemfile.lock specifying:
      """
      GEM
        specs:
          foo (1.0.0)

      """
    And the initial bundle install committed
    When I run `keep_up`
    Then the stdout should contain:
      """
      Updating foo
      Updated foo to 1.0.1
      """
    And the gemspec for "bar" should depend on "foo" at version "1.0.1"
    And the file "Gemfile.lock" should contain:
      """
      foo (1.0.1)
      """
