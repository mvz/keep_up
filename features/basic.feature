Feature: Update bundle
  As a developer
  In order to avoid tedious work
  I want to automatically update dependencies

  Scenario: Nothing to do
    Given the following remote gems:
      | name | version |
      | foo  | 1.0.0   |
    And a Gemfile specifying:
      """
      gem 'foo', '1.0.0'
      """
    And a Gemfile.lock specifying:
      """
      GEM
        specs:
          foo (1.0.0)

      """
    And the initial bundle install committed
    When I run `keep_up`
    Then the stdout from "keep_up" should contain exactly:
      """
      All done!
      """
    And the file "Gemfile.lock" should contain:
      """
      foo (1.0.0)
      """

  Scenario: Updating a gem with a fixed version
    Given the following remote gems:
      | name | version |
      | foo  | 1.0.0   |
      | foo  | 1.0.1   |
    And a Gemfile specifying:
      """
      gem 'foo', '1.0.0'
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
      Updated foo to 1.0.1
      All done!
      """
    And the file "Gemfile" should contain:
      """
      gem 'foo', '1.0.1'
      """
    And the file "Gemfile.lock" should contain:
      """
      foo (1.0.1)
      """
    When I run `git log`
    Then the stdout should contain:
      """
      Update foo to version 1.0.1
      """
