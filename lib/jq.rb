require 'multi_json'
require 'tempfile'
require 'stringio'

require 'jq_core'
require 'jq/version'
require 'jq/parser'

def JQ(src, options = {})
  JQ::Parser.new(src, options)
end
