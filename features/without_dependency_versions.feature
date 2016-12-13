Feature: Update bundle with no depenency versions
  As a developer
  In order to avoid editing the Gemfile
  I want to specify no versions

  Scenario: Updating an unversioned depedency
    Given a Gemfile specifying:
      """
      gem 'foo'
      """
    And a gem named "foo" at version "1.0.0"
    And the initial bundle install committed
    And a gem named "foo" at version "1.0.1"
    When I run `keep_up --test-command true`
    Then the output should contain:
      """
      Updating foo to 1.0.1
      """
    And the file "Gemfile" should contain:
      """
      path 'libs'

      gem 'foo'
      """
    And the file "Gemfile.lock" should contain:
      """
      foo (1.0.1)
      """
