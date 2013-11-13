require 'jq_core'
require 'json'

class JQ::Parser
  BUFSIZ = 4096

  def initialize(src, options = {})
    @src = src.kind_of?(IO) ? src : src.to_s
    @options = {
      :parse_json => true,
    }.merge(options)
  end

  def search(program, &block)
    @src.rewind if @src.kind_of?(IO)
    retval = nil

    if block
      block_orig = block

      block = proc do |str|
        block_orig.call(parse_json(str))
      end
    else
      retval = []

      block = proc do |str|
        retval << parse_json(str)
      end
    end

    jq(program) do |jq_core|
      if @src.kind_of?(IO)
        while buf = @src.read(BUFSIZ)
          jq_core.update(buf, !src.eof?, &block)
        end
      else
        jq_core.update(@src, false, &block)
      end
    end

    return retval
  end

  private
  def jq(program)
    jq_core = nil

    begin
      jq_core = JQ::Core.new(program)
      retval = yield(jq_core)
    ensure
      jq_core.close if jq_core
    end
  end

  def parse_json(str)
    if @options[:parse_json]
      JSON.parse("[#{str}]").first
    else
      str
    end
  end
end
