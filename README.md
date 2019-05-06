# ruby-jq

Ruby bindings for jq.

see [http://stedolan.github.io/jq/](http://stedolan.github.io/jq/).

[![Gem Version](https://badge.fury.io/rb/ruby-jq.svg)](http://badge.fury.io/rb/ruby-jq)
[![Build Status](https://travis-ci.org/winebarrel/ruby-jq.svg?branch=master)](https://travis-ci.org/winebarrel/ruby-jq)

## Prerequisites

jq requires the Oniguruma library to provide regex support. To install Oniguruma
for your system, please follow the instructions in the [jq FAQ](https://github.com/stedolan/jq/wiki/FAQ#installation).

## Installation

Add this line to your application's Gemfile:

    gem 'ruby-jq'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby-jq

### Using system libraries

By default, ruby-jq downloads and compiles its own version of libjq. If you
would like to use your own version of libjq, you can skip this process by
passing the `--use-system-libraries` flag to `gem install`, or by setting the
`RUBYJQ_USE_SYSTEM_LIBRARIES` env var.

## Usage

```ruby
require 'jq'

src = <<EOS
[
  "FOO",
  {
    "BAR": [100, 200]
  },
  1.23,
  [1, "2", 3]
]
EOS

jq = JQ(src)

jq.search('.[]') do |value|
  p value
  # => "FOO"
  # => {"BAR"=>[100, 200]}
  # => 1.23
  # => [1, "2", 3]
end

jq = JQ(src, :parse_json => false)

jq.search('.[1].BAR') do |value|
  p value
  # => "[100,200]"
end
```

### Query for Hash/Array

```ruby
require 'jq/extend'

p {'FOO' => 100, 'BAR' => [200, 200]}.jq('.BAR[]')
# => [200, 200]

['FOO', 100, 'BAR', [200, 200]].jq('.[3][]') do |value|
  p value
  # => 200
end
```
