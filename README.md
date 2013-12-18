# ruby-jq

Ruby bindings for jq.

see [http://stedolan.github.io/jq/](http://stedolan.github.io/jq/).

[![Gem Version](https://badge.fury.io/rb/ruby-jq.png)](http://badge.fury.io/rb/ruby-jq)
[![Build Status](https://drone.io/bitbucket.org/winebarrel/ruby-jq/status.png)](https://drone.io/bitbucket.org/winebarrel/ruby-jq/latest)

## Installation

First, please install libjq from HEAD of [git repository](https://github.com/stedolan/jq).

```sh
git clone https://github.com/stedolan/jq.git
cd jq
autoreconf -i
./configure --enable-shared
make
sudo make install
sudo ldconfig
```

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
