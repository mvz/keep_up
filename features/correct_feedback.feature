Feature: Correct feedback
  As a developer
  In order to know what's going on
  I want correct feedback in unusal cases

  Scenario: Gem not updated to its latest version
    Given the following remote gems:
      | name | version |
      | bar  | 1.0.0   |
      | bar  | 1.1.0   |
      | bar  | 1.2.0   |
    And a Gemfile specifying:
      """
      gem 'bar', ['>= 1.0.0', '< 1.2.0']
      """
    And a Gemfile.lock specifying:
      """
      GEM
        specs:
          bar (1.0.0)

      """
    And the initial bundle install committed
    When I run `keep_up`
    Then the output should contain:
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
    Given the following remote gems:
      | name | version |
      | bar  | 1.0.0   |
      | bar  | 1.2.0   |
    And a Gemfile specifying:
      """
      gem 'bar', ['>= 1.0.0', '< 1.2.0']
      """
    And a Gemfile.lock specifying:
      """
      GEM
        specs:
          bar (1.0.0)

      """
    And the initial bundle install committed
    When I run `keep_up`
    Then the stdout should contain:
      """
      Updating bar
      Failed updating bar to 1.2.0
      All done!
      """
