require 'mkmf'

if have_library('jq')
  create_makefile('cjq')
end
