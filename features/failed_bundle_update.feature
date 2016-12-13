Feature: Skip failing updates
  As a developer
  In order te have updates automated as much as possible
  I want failed updates to be skipped

  Scenario: Skipping due to version conflict
    Given a Gemfile specifying:
      """
      gem 'bar', '1.0.0'
      gem 'foo', '1.0.0'
      """
    And a gem named "bar" at version "1.0.0"
    And a gem named "foo" at version "1.0.0"
    And the initial bundle install committed
    And a gem named "bar" at version "1.2.0" depending on "foo" at version "1.2.0"
    And a gem named "foo" at version "1.2.0"
    When I run `keep_up --test-command true`
    Then the output should contain:
      """
      Updating bar to 1.2.0
      Update failed
      Updating foo to 1.2.0
      """
    And the output should contain:
      """
      Bundle up to date!
      All done!
      """
    And the file "Gemfile.lock" should contain:
      """
          bar (1.0.0)
          foo (1.2.0)
      """

