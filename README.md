# Gem::Checkout

RubyGems addon command ('checkout') which, given a gem, will checkout the matching sources at the same version.

Why? So you no longer have to work out where the source code for a given gem is.

(Which allows you to automate a LOT of tasks given just a gem name!).

For example:

```bash
$ gem checkout nenv -v 0.2.0
```

will checkout the GitHub source code (into the current dir) for the `nenv` gem at `0.2.0` (commit: beb9981)


## Installation

Add this line to your application's Gemfile:

```sh
gem install gem-checkout
```

## Usage

Proof of concept right now, so open issues and/or PRs for improvements.

Options:

```
-d LEVEL
```
sets the debug level, where 0=debug, 1=warn, and so on...

```
-v, --version VERSION
```

The version of the gem to you want to hack on - the repo and revision will be discovered.

(If you don't provide this option, the latest version will be used).

## FAQ

None yet, so open an issue...


## Development

```
bundle install
bundle exec guard
```

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/e2/gem-checkout

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
