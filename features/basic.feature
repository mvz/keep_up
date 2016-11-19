Feature: Update bundle
  As a developer
  In order to avoid tedious work
  I want to automatically update dependencies

  Background: A project with fixed dependency versions
    Given a Gemfile specifying:
      """
      gem 'foo', '1.0.0'
      """
    And a gem named "foo" at version 1.0.0
    When I run `bundle install`
    Then the output should contain:
      """
      Using foo 1.0.0
      """
    When I run `git init`
    And I run `git add .`
    And I run `git ci -am 'Initial'`

  Scenario: Nothing to do
    When I run `keep_up --test-command true`
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
    Given a gem named "foo" at version 1.0.1
    When I run `keep_up --test-command true`
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
