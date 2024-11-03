Feature: Update bundle with no depenency versions
  As a developer
  In order to avoid editing the Gemfile
  I want to specify no versions

  Scenario: Updating an unversioned depedency
    Given the following remote gems:
      | name | version |
      | foo  | 1.0.0   |
      | foo  | 1.0.1   |
    And a Gemfile specifying:
      """
      gem 'foo'
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
      """
    And the file "Gemfile" should contain:
      """
      gem 'foo'
      """
    And the file "Gemfile.lock" should contain:
      """
      foo (1.0.1)
      """
