Feature: Skip failing updates
  As a developer
  In order te have updates automated as much as possible
  I want failed updates to be skipped

  Scenario: Skipping due to version conflict
    Given the following remote gems:
      | name | version | depending on | at version |
      | bar  | 1.0.0   |              |            |
      | foo  | 1.0.0   |              |            |
      | bar  | 1.2.0   | foo          | 1.2.0      |
      | foo  | 1.2.0   |              |            |
    And a Gemfile specifying:
      """
      gem 'bar', '1.0.0'
      gem 'foo', '1.0.0'
      """
    And a Gemfile.lock specifying:
      """
      GEM
        specs:
          foo (1.0.0)
          bar (1.0.0)

      """
    And the initial bundle install committed
    When I run `keep_up`
    Then the stdout should contain:
      """
      Updating bar
      Failed updating bar to 1.2.0
      Updating foo
      Updated foo to 1.2.0
      """
    And the stdout should contain:
      """
      All done!
      """
    And the file "Gemfile.lock" should contain:
      """
          bar (1.0.0)
          foo (1.2.0)
      """

