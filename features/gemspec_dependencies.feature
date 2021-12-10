Feature: Gemspec dependencies
  As a developer
  In order to keep my gem up to date
  I want to update dependencies in a gemspec

  Scenario: Updating a gemspec with fixed dependency versions
    Given a Gemfile specifying:
      """
      gemspec
      """
    And a gemspec for "bar" depending on "foo" at version "1.0.0"
    And a gem named "foo" at version "1.0.0"
    And the initial bundle install committed
    Then the file "Gemfile.lock" should contain:
      """
      foo (1.0.0)
      """
    Given a gem named "foo" at version "1.0.1"
    When I run `keep_up`
    Then the output should contain:
      """
      Updating foo
      Updated foo to 1.0.1
      """
    And the gemspec for "bar" should depend on "foo" at version "1.0.1"
    And the file "Gemfile.lock" should contain:
      """
      foo (1.0.1)
      """
