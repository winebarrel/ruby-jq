# frozen_string_literal: true

require 'multi_json'
require 'tempfile'
require 'stringio'

require 'jq_core'
require 'jq/version'
require 'jq/parser'

def JQ(src, parse_json: true) # rubocop:disable Naming/MethodName
  JQ::Parser.new(src, parse_json: parse_json)
end
