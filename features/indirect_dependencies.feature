Feature: Updating indirect dependencies
  As a developer
  To stay fully up to date
  I want to also update dependencies I haven't specified myself

  Scenario: An indirect dependency has an update
    Given the following remote gems:
      | name | version | depending on | at version |
      | foo  | 1.0.0   | bar          | ~> 1.0.0   |
      | bar  | 1.0.0   |              |            |
      | bar  | 1.0.1   |              |            |
    And a Gemfile specifying:
      """
      gem 'foo', '1.0.0'
      """
    And a Gemfile.lock specifying:
      """
      GEM
        specs:
          bar (1.0.0)
          foo (1.0.0)
            bar (~> 1.0.0)

      """
    And the initial bundle install committed
    When I run `keep_up`
    Then the stdout should contain exactly:
      """
      Updating bar
      Updated bar to 1.0.1
      All done!
      """
    And the file "Gemfile.lock" should contain:
      """
          bar (1.0.1)
          foo (1.0.0)
      """
