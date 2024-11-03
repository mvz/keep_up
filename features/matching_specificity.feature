Feature: Matching specificity correctly
  As a developer
  In order to avoid version conflicts
  I want to trust semantic versioning

  Scenario: Matching specificity while updating a gemspec
    Given the following remote gems:
      | name | version |
      | foo  | 1.0.0   |
      | foo  | 2.1.1   |
    And a Gemfile specifying:
      """
      gemspec
      """
    And a gemspec for "bar" depending on "foo" at version "~> 1.0"
    And a Gemfile.lock specifying:
      """
      GEM
        specs:
          foo (1.0.0)

      """
    And the initial bundle install committed
    When I run `keep_up`
    Then the stdout should contain:
      """
      Updating foo
      Updated foo to 2.1.1
      """
    And the gemspec for "bar" should depend on "foo" at version "~> 2.1"
    And the file "Gemfile.lock" should contain:
      """
      foo (2.1.1)
      """
    When I run `git log`
    Then the stdout should contain:
      """
      Update foo to version 2.1
      """

  Scenario: Matching specificity while updating a Gemfile
    Given the following remote gems:
      | name | version |
      | foo  | 1.0.0   |
      | foo  | 2.1.1   |
    And a Gemfile specifying:
      """
      gem 'foo', '~> 1.0'
      """
    And a Gemfile.lock specifying:
      """
      GEM
        specs:
          foo (1.0.0)

      """
    And the initial bundle install committed
    When I run `keep_up`
    Then the stdout should contain:
      """
      Updating foo
      Updated foo to 2.1.1
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
    Then the stdout should contain:
      """
      Update foo to version 2.1
      """
    And the stdout should not contain:
      """
      Update foo to version 2.1.1
      """
