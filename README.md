# Exim

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'exim'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install exim

## Usage

Add your Method in class model

Exim::Exporter.to_csv(NameModel)

and in your controller use
  respond_to do |format|
      format.csv { send_data @variable }
  end


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
