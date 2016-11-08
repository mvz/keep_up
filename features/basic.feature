Feature: Update bundle
  As a developer
  In order to avoid tedious work
  I want to automatically update dependencies

  Scenario: Nothing to do
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
    And I run `keep_up --test-command true`
    Then the output should contain:
      """
      Bundle up to date!
      All done!
      """
