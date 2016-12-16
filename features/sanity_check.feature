Feature: Sanity check
  As a developer
  In order to not shoot myself in the foot
  I want to have some checks done before keep_up starts

  Scenario: Check clean checkout directory
    Given a Gemfile specifying:
      """
      gem 'foo', '1.0.0'
      """
    And a gem named "foo" at version "1.0.0"
    And the initial bundle install committed
    And a gem named "foo" at version "1.0.1"
    When I add a file without checking it in
    And I run `keep_up`
    Then the output should not contain:
      """
      Updating foo to 1.0.1
      """
    And the output should contain:
      """
      Commit or stash your work before running 'keep_up'
      """
