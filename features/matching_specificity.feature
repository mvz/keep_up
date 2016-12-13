Feature: Matching specificity correctly
  As a gem developer
  In order to avoid version conflicts for my users
  I want to trust semantic versioning

  Background: A project depending an a mature gem
    Given a Gemfile specifying:
      """
      gemspec
      """
    And a gemspec for "bar" depending on "foo" at version "~> 1.0"
    And a gem named "foo" at version "1.0.0"
    And the initial bundle install committed

  Scenario: Matching specificity while updating
    Given a gem named "foo" at version "2.1.1"
    When I run `keep_up --test-command true`
    Then the output should contain:
      """
      Updating foo to 2.1.1
      """
    And the gemspec for "bar" should depend on "foo" at version "~> 2.1"
    And the file "Gemfile.lock" should contain:
      """
      foo (2.1.1)
      """
    When I run `git log`
    Then the output should contain:
      """
      Update foo to 2.1
      """
