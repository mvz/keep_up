Feature: Matching specificity correctly
  As a developer
  In order to avoid version conflicts
  I want to trust semantic versioning

  Scenario: Matching specificity while updating a gemspec
    Given a Gemfile specifying:
      """
      gemspec
      """
    And a gemspec for "bar" depending on "foo" at version "~> 1.0"
    And a gem named "foo" at version "1.0.0"
    And the initial bundle install committed
    And a gem named "foo" at version "2.1.1"
    When I run `keep_up`
    Then the output should contain:
      """
      Updating foo to 2.1.1
      """
    And the gemspec for "bar" should depend on "foo" at version "~> 2.1"
    And the file "Gemfile.lock" should contain:
      """
      foo (2.1.1)
      """
    When I run `git log`
    Then the output should contain:
      """
      Update foo to version 2.1
      """

  Scenario: Matching specificity while updating a Gemfile
    Given a Gemfile specifying:
      """
      gem 'foo', '~> 1.0'
      """
    And a gem named "foo" at version "1.0.0"
    And the initial bundle install committed
    And a gem named "foo" at version "2.1.1"
    When I run `keep_up`
    Then the output should contain:
      """
      Updating foo to 2.1.1
      """
    And the file "Gemfile" should contain:
      """
      gem 'foo', '~> 2.1'
      """
    And the file "Gemfile.lock" should contain:
      """
      foo (2.1.1)
      """
    When I run `git log`
    Then the output should contain:
      """
      Update foo to version 2.1
      """
