require 'jq/version'
require 'jq/parser'

def JQ(src, options = {})
  JQ::Parser.new(src, options)
end
