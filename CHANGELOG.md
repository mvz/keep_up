# Changelog

## 0.11.0 / 2023-09-22

* Drop support for Ruby 2.6 ([#102] by [mvz])
* Add support for Ruby 3.2 ([#103] by [mvz])

[mvz]: https://github.com/mvz
[#102]: https://github.com/mvz/keep_up/pull/102
[#103]: https://github.com/mvz/keep_up/pull/103

## 0.10.2 / 2022-09-23

* Detect version update even if `bundle update` does not print old version

## 0.10.1 / 2022-05-20

* Adjust commit message to match update specificity

## 0.10.0 / 2022-01-23

* Drop support for Ruby 2.5
* Add support for Ruby 3.0 and 3.1
* Avoid interrupting half-printed lines when bundle update fails

## 0.9.0 / 2020-09-18

* Drop support for Ruby 2.4
* Improve wording for commit messages

## 0.8.1 / 2019-12-30

* Silence keyword arguments deprecation on Ruby 2.7

## 0.8.0 / 2019-10-16

* Drop support for Ruby 2.3
* Handle use of `require_relative` in gemspec files

## 0.7.1 / 2019-01-16

* Support Ruby 2.6
* Support Bundler 2.x

## 0.7.0 / 2018-12-10

* Interface with Bundler via its CLI
* Perform a real `bundle update` for each update dependency. This means gems
  will actually be installed in each step.
* Drop support for Bundler versions below 1.15.
* Delegate finding available update candidates to Bundler.
* Gracefully handle git dependencies when collecting update candidates
* Do not attempt to update requirements with more than one element
* Restore effect of the `--local` flag.

## 0.6.3 / 2017-10-27

* Filter out pre-releases when searching for dependencies to support
  Bundler 1.16.

## 0.6.2 / 2017-05-23

* Support Bundler 1.15

## 0.6.1 / 2017-04-19

* Update indirect dependencies in addition to direct ones

## 0.6.0 / 2017-02-04

* Show actual resulting new version for each update
* Fail if only dependencies were updated
* Fail if Bundler downgrades the selected dependency
* Replace use of custom 'ci' git alias with 'commit'

## 0.5.1 / 2016-12-17

* Handle extra and unusual whitespace when updating Gemfile and gemspec

## 0.5.0 / 2016-12-16

* Match existing specificity of versions when updating them
* Stop eating people's homework by doing some sanity checks at the start

## 0.4.0 / 2016-12-11

* Allow local operation
* Handle explicitely frozen strings in gemspecs

## 0.3.0 / 2016-11-30

* Allow specifying gems to skip and not to attempt updates for

## 0.2.0 / 2016-11-24

* Resolve remotely to ensure list of available gems is fetched
* Do not attempt to 'upgrade' to a lower version
* Depend on Bundler 1.13 since keep_up uses stuff that's not in Bundler 1.12

## 0.1.0 / 2016-11-23

* Initial release.
