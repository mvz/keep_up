Feature: Update bundle with approximate versions
  As a developer
  In order to avoid updating fixed versions very often
  I want to have approximate versions

  Background: A project with approximate dependency versions
    Given a Gemfile specifying:
      """
      gem 'foo', '~> 1.0.0'
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

  Scenario: Updating to a version that matches the current spec
    Given a gem named "foo" at version 1.0.1
    When I run `keep_up --test-command true`
    Then the output should contain:
      """
      Updating foo to 1.0.1
      """
    And the file "Gemfile" should contain:
      """
      path 'libs'

      gem 'foo', '~> 1.0.0'
      """

  Scenario: Updating to a version that exceeds the current spec
    Given a gem named "foo" at version 1.1.2
    When I run `keep_up --test-command true`
    Then the output should contain:
      """
      Updating foo to 1.1.2
      """
    And the file "Gemfile" should contain:
      """
      path 'libs'

      gem 'foo', '~> 1.1.2'
      """