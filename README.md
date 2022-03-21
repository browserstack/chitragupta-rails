# Chitragupta

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'chitragupta', git: "git://github.com/browserstack/chitragupta-rails.git"
```

## Usage

### Configuring
Add the following line in either `application.rb` or `<environment>.rb`

```ruby
require "chitragupta"

Chitragupta::setup_application_logger(RailsApplicationModule, :current_user_function)
```
The `RailsApplicationModule` should be replaced with the rails application module.
The `:current_user_function` should be replaced with a symbol of the callable which when called returns the current user object.

### Ruby Server Application
Sample code block:
```ruby
require "chitragupta"

cg_logger = Logger.new('/tmp/already_existing_logfile.log')
cg_logger.formatter = Chitragupta::JsonLogFormatter.new

# for sinatra application
Chitragupta.payload = {
  'method': request.request_method,
  'path': request.path_info,
  'ip': request.ip,
  'request_id': 1234, # Request ID goes here
  'user_id': 1, # Requesting user ID goes here
  'params': request.params
}
cg_logger.info({"status": 200, # status code of server request
                "duration": 100,
                "log": { "id": 12345,
                         "kind": "dc_log_migration", # Log kind to be added here
                         "dynamic_data": "Starting remote call for URL"}
               })

```

### Additional Logging
You can use `Rails.logger`
OR
You can create logger object as follows
```
logger = Chitragupta::Logger.new(STDOUT)
```

In case you have custom logger objects created, you can change the formatter(as below) to ensure the logs are structured.
```
logger = Logger.new(STDOUT)
logger.formatter = Chitragupta::JsonLogFormatter.new
```

Passing values for `log.*` or `meta.*`
```
Rails.logger.info({ log: { id: 'some-unique-id', kind: 'UNIQUE_KIND' }})
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/browserstack/chitragupta-rails.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
