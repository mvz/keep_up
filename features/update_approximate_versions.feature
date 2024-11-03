Feature: Update bundle with approximate versions
  As a developer
  In order to avoid updating fixed versions very often
  I want to have approximate versions

  Background: A project with approximate dependency versions
    Given a Gemfile specifying:
      """
      gem 'foo', '~> 1.0.0'
      """
    And a Gemfile.lock specifying:
      """
      GEM
        specs:
          foo (1.0.0)

      """

  Scenario: Updating to a version that matches the current spec
    Given the following remote gems:
      | name | version |
      | foo  | 1.0.0   |
      | foo  | 1.0.1   |
    And the initial bundle install committed
    When I run `keep_up`
    Then the stdout should contain:
      """
      Updating foo
      Updated foo to 1.0.1
      """
    And the file "Gemfile" should contain:
      """
      gem 'foo', '~> 1.0.0'
      """
    And the file "Gemfile.lock" should contain:
      """
      foo (1.0.1)
      """

  Scenario: Updating to a version that exceeds the current spec
    Given the following remote gems:
      | name | version |
      | foo  | 1.0.0   |
      | foo  | 1.1.2   |
    And the initial bundle install committed
    When I run `keep_up`
    Then the stdout should contain:
      """
      Updating foo
      Updated foo to 1.1.2
      """
    And the file "Gemfile" should contain:
      """
      gem 'foo', '~> 1.1.2'
      """
    And the file "Gemfile.lock" should contain:
      """
      foo (1.1.2)
      """
