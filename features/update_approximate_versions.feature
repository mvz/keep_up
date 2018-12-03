Feature: Update bundle with approximate versions
  When updating a bundle with approximate versions, i.e., using ~>, keep_up
  will keep the specified version string if the latest version matches it. If
  the latest version exceeds the specified version, it will update the
  specified version.

  Scenario: Updating project with approximate dependency versions
    Given a Gemfile specifying:
      """
      gem 'foo', '~> 1.0.0'
      gem 'bar', '~> 1.0.0'
      """
    And a gem named "foo" at version "1.0.0"
    And a gem named "bar" at version "1.0.0"
    And the initial bundle install committed
    When the gem named "foo" is updated to version "1.0.1"
    And the gem named "bar" is updated to version "1.1.2"
    And I run `keep_up`
    Then the output should contain:
      """
      Updating bar to 1.1.2
      Updating foo to 1.0.1
      """
    And the file "Gemfile" should contain:
      """
      path 'libs'

      gem 'foo', '~> 1.0.0'
      gem 'bar', '~> 1.1.2'
      """
    And the file "Gemfile.lock" should contain:
      """
          bar (1.1.2)
          foo (1.0.1)
      """
