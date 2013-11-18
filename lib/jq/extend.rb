require 'jq'

module JQ::Extend
  def jq(program, &block)
    src = JSON(self)
    JQ(src).search(program, &block)
  end
end

class Hash;  include JQ::Extend; end
class Array; include JQ::Extend; end
