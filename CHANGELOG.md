# Changelog

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
