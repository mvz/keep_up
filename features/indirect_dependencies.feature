Feature: Updating indirect dependencies
  As a developer
  To stay fully up to date
  I want to also update dependencies I haven't specified myself

  Scenario: An indirect dependency has an update
    Given a Gemfile specifying:
      """
      gem 'foo', '1.0.0'
      """
    And a gem named "foo" at version "1.0.0" depending on "bar" at version "~> 1.0.0"
    And a gem named "bar" at version "1.0.0"
    And the initial bundle install committed
    And a gem named "bar" at version "1.0.1"
    When I run `keep_up`
    Then the output should contain exactly:
      """
      Updating bar to 1.0.1
      All done!
      """
    And the file "Gemfile.lock" should contain:
      """
          bar (1.0.1)
          foo (1.0.0)
      """
