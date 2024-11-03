Feature: Skipping dependencies
  As a developer
  In order to avoid having to deal with untested incompatibilities
  I want to be able to skip specific gems while updating

  Scenario: Specifying gems to skip on the command line
    Given the following remote gems:
      | name | version |
      | foo  | 1.0.0   |
      | foo  | 1.2.0   |
      | bar  | 1.0.0   |
      | bar  | 1.2.0   |
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
    When I run `keep_up --skip bar`
    Then the stdout should contain:
      """
      Updating foo
      Updated foo to 1.2.0
      All done!
      """
    And the file "Gemfile.lock" should contain:
      """
          bar (1.0.0)
          foo (1.2.0)
      """


