# ruby-jq

Ruby binding for JQ.

see http://stedolan.github.io/jq/

## Installation

First, please install libjq from HEAD of [git repository](https://github.com/stedolan/jq).

Add this line to your application's Gemfile:

    gem 'ruby-jq'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby-jq

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

jq.search('.[]') do |value|
  p value
  # => "\"FOO\""
  # => "{\"BAR\":[100,200]}"
  # => "1.23"
  # => "[1,\"2\",3]"
end
```
