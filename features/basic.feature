Feature: Update bundle
  As a developer
  In order to avoid tedious work
  I want to automatically update dependencies

  Background: A project with fixed dependency versions
    Given a Gemfile specifying:
      """
      gem 'foo', '1.0.0'
      """
    And a gem named "foo" at version "1.0.0"
    And the initial bundle install committed

  Scenario: Nothing to do
    When I run `keep_up`
    Then the output should not contain:
      """
      Updating foo to 1.0.0
      """
    And the output should contain:
      """
      Bundle up to date!
      All done!
      """
    And the file "Gemfile.lock" should contain:
      """
      foo (1.0.0)
      """

  Scenario: Updating a gem with a fixed version
    Given a gem named "foo" at version "1.0.1"
    When I run `keep_up`
    Then the output should contain:
      """
      Updating foo to 1.0.1
      """
    And the file "Gemfile" should contain:
      """
      path 'libs'

      gem 'foo', '1.0.1'
      """
    And the file "Gemfile.lock" should contain:
      """
      foo (1.0.1)
      """
    When I run `git log`
    Then the output should contain:
      """
      Update foo to 1.0.1
      """
