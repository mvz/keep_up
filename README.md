# KeepUp

Automatically update your dependencies.

## Installation

KeepUp is not intended to be part of your application's bundle. You should
install it yourself as:

    $ gem install keep_up

## Basic Usage

KeepUp only works with git at the moment!

Before running KeepUp, it's probably nice to start a new branch. Also, KeepUp
will refuse to run if your checkout directory is not clean, or if your
Gemfile.lock is not up-to-date.

Run keep_up in your project directory:

    $ keep_up

KeepUp will proceed to update your dependencies one by one, committing each
change if updating the bundle is succesful.

Next, run `bundle install` and run your tests or whatever. Since KeepUp
generates a separate commit for each succesful update, you can use `git bisect`
to find any updates that cause problems and remove or fix them.

## Options

* You can pass `--skip <GEMNAME>` to make KeepUp not consider the named gem for
  upgrades. This is helpful if you know a given upgrade is problematic. This
  option can be passed multiple times.
* You can pass `--local` to make KeepUp not try to fetch remote gem version
  information.

## Planned Features

* Allow some check for each change. My feeling at the moment is that for local,
  supervised use it's best to test everything at once at the end and then go
  back and fix things. However, for automation it may be helpful to fully check
  each commit.
* Automatically set up a new branch so you don't have to.
* Create a pull request with the created commits.
* Re-try with combinations of updates if single updates don't work: Sometimes
  two or more dependencies need to be updated together due to their
  interdependencies.

## Development

After checking out the repo, run `script/setup` to install dependencies. Then, run
`rake spec` to run the tests. You can also run `script/console` for an interactive
prompt that will allow you to experiment.

You can run `keep_up` from the checked-out repo by running `ruby -Ilib bin/keep_up`.

To install this gem onto your local machine, run `bundle exec rake install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake release`, which will create a git tag for the version, push
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/mvz/keep_up. This project is intended to be a safe,
welcoming space for collaboration, and contributors are expected to adhere to
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
