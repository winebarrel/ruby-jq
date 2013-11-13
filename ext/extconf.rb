require 'mkmf'

if have_library('jq')
  create_makefile('jq_core')
end
