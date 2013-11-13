%w(lib ext).each {|i| $: << File.dirname(__FILE__) + "/../#{i}" }
require 'jq'