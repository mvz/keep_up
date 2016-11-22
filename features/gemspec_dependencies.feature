Feature: Gemspec dependencies
  As a developer
  In order to keep my gem up to date
  I want to update dependencies in a gemspec

  Scenario: Updating a gemspec with fixed dependency versions
    Given a Gemfile specifying:
      """
      gemspec
      """
    And a gemspec for "bar" specifying:
      """
      spec.add_runtime_dependency 'foo', '1.0.0'
      """
    And a gem named "foo" at version 1.0.0
    And the initial bundle install committed
    And a gem named "foo" at version 1.0.1
    When I run `keep_up --test-command true`
    Then the output should contain:
      """
      Updating foo to 1.0.1
      """
    And the file "bar.gemspec" should contain:
      """
      spec.add_runtime_dependency 'foo', '1.0.1'
      """
    And the file "Gemfile.lock" should contain:
      """
      foo (1.0.1)
      """
