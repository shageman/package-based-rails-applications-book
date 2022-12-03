# Pocky

Pocky generates dependency graphs for your packwerk packages. The gem is named after pocky, a beloved Japanese snack that comes in small packages.


## Usage

Invoke from irb or code.

```ruby
Pocky::Packwerk.generate
```

Invoke as a rake task:

    $ rake pocky:generate


![packwerk](https://user-images.githubusercontent.com/138784/104111683-df043180-5299-11eb-9a37-8db6851062e0.png)


#### Generate with custom options
```ruby
Pocky::Packwerk.generate(
  package_path: 'app/packages', # Relative path to packages directory
  default_package: 'app',       # The default package listed as "." in package.yml and deprecated_references.yml
  filename: 'packwerk.png',     # Name of output file
  dpi: 100,                     # Output file resolution
  package_color: '#5CC8FF',   # color name or hex color, see https://graphviz.org/doc/info/colors.html for more details
  deprecated_reference_edge: 'black',
  dependency_edge: 'darkgreen',
)
```

Note that the the bold edges indicate heavier dependencies.

Invoke as a rake task:

    $ rake pocky:generate"[app/packages,Monolith,packages.png,100]"


#### Generate subsystem graph (`package_path` as an array)
`package_path` can also be an array in case your packages are organized in multiple directories. Alternatively, you can also provide paths to individual packages to generate more focused graphs for your package subsystems.

```ruby
Pocky::Packwerk.generate(
  package_path: [
    'app/packages/a',
    'app/packages/z',
  ]
)
```

Generate the same graph using the rake task:

    $ rake pocky:generate"[app/packages/a app/packages/z]"


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pocky'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install pocky

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mquan/pocky.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
