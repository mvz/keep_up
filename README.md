# KeepUp

Automatically update your dependencies.

## Installation

THIS GEM IS HIGHLY EXPERIMENTAL AND WILL EAT YOUR HOMEWORK!

KeepUp is not intended to be part of your application's bundle. You should
install it yourself as:

    $ gem install keep_up

## Usage

Run keep_up in your project directory:

    $ keep_up

KeepUp will do its thing and create a pull request or bug report.

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
