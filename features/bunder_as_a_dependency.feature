Feature: Update bundle with bundler as a dependency
  As a developer
  In order to avoid annoyance
  I want keep_up to handle bundler as a dependency

  Background: A project with bundler as a dependency
    Given a Gemfile specifying:
      """
      gem 'foo', '1.0.0'
      gem 'bundler'
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

  Scenario: Updating foo
    Given a gem named "foo" at version 1.0.1
    When I run `keep_up --test-command true`
    Then the output should contain:
      """
      Updating foo to 1.0.1
      """
    And the file "Gemfile" should contain:
      """
      gem 'foo', '1.0.1'
      """

