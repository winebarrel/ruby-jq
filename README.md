```ruby
require './cjq'

jq_core = nil

begin
  jq_core = JQ::Core.new('.[]')

  jq_core.update('[{"FOO":100},{"BAR":200}]', false) do |str|
    p str
  end
ensure
  jq_core.close if jq_core
end
```
