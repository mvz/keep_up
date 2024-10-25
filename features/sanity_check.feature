Feature: Sanity check
  As a developer
  In order to not shoot myself in the foot
  I want to have some checks done before keep_up starts

  Scenario: Check clean checkout directory
    Given a Gemfile specifying:
      """
      gem 'foo', '1.0.0'
      """
    And a gem named "foo" at version "1.0.0"
    And the initial bundle install committed
    And a gem named "foo" at version "1.0.1"
    When I add a file without checking it in
    And I run `keep_up`
    Then the stdout should not contain:
      """
      Updating foo
      Updated foo to 1.0.1
      """
    And the stderr should contain:
      """
      Commit or stash your work before running 'keep_up'
      """

  Scenario: Check bundle status
    Given a Gemfile specifying:
      """
      gem 'foo', '1.0.1'
      """
    And a gem named "foo" at version "1.0.0"
    And a gem named "foo" at version "1.0.1"
    And the initial bundle install committed
    When I update the Gemfile to specify:
      """
      gem 'foo', '1.0.0'
      """
    And I commit the changes without updating the bundle
    And I run `keep_up`
    Then the stdout should not contain:
      """
      Updating foo
      Updated foo to 1.0.1
      """
    And the stderr should contain:
      """
      Make sure your Gemfile.lock is up-to-date before running 'keep_up'
      """
    When I run `git status`
    Then the stdout should contain:
      """
      nothing to commit, working tree clean
      """
