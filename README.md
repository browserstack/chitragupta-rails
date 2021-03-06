# Chitragupta

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chitragupta', git: "git://github.com/browserstack/chitragupta-rails.git"
```

## Usage

Add the following line in either `application.rb` or `<environment>.rb`

```ruby
require "chitragupta"

Chitragupta::setup_application_logger(RailsApplicationModule, :current_user_function)
```
The `RailsApplicationModule` should be replaced with the rails application module.
The `:current_user_function` should be replaced with a symbol of the callable which when called returns the current user object.

In case you have custom logger objects created, you can change the formatter(as below) to ensure the logs are structured.
```
logger = Logger.new(STDOUT)
logger.formatter = Chitragupta::JsonLogFormatter.new
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/browserstack/chitragupta.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
