Feature: Correct feedback
  As a developer
  In order to know what's going on
  I want correct feedback in unusal cases

  Scenario: Gem not updated to its latest version
    Given a Gemfile specifying:
      """
      gem 'bar', ['>= 1.0.0', '< 1.2.0']
      """
    And a gem named "bar" at version "1.0.0"
    And the initial bundle install committed
    And a gem named "bar" at version "1.1.0"
    And a gem named "bar" at version "1.2.0"
    When I run `keep_up`
    Then the stdout should contain:
      """
      Updating bar
      Updated bar to 1.1.0
      All done!
      """

    And the file "Gemfile.lock" should contain:
      """
          bar (1.1.0)
      """
    When I run `git log`
    Then the stdout should contain:
      """
      Update bar to version 1.1.0
      """

  Scenario: Gem not updated at all
    Given a Gemfile specifying:
      """
      gem 'bar', ['>= 1.0.0', '< 1.2.0']
      """
    And a gem named "bar" at version "1.0.0"
    And the initial bundle install committed
    And a gem named "bar" at version "1.2.0"
    When I run `keep_up`
    Then the stdout should contain:
      """
      Updating bar
      Failed updating bar to 1.2.0
      All done!
      """
