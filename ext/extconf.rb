# frozen_string_literal: true

require 'mkmf'

def using_system_libraries?
  arg_config('--use-system-libraries', ENV.key?('RUBYJQ_USE_SYSTEM_LIBRARIES'))
end

unless using_system_libraries?
  message "Buildling jq using packaged libraries.\n"

  require 'rubygems'
  require 'mini_portile2'

  recipe = MiniPortile.new('jq', '1.6')
  recipe.files = ['https://github.com/stedolan/jq/archive/jq-1.6.tar.gz']
  recipe.configure_options = [
    '--enable-shared',
    '--disable-maintainer-mode'
  ]
  class << recipe
    def configure
      # https://github.com/stedolan/jq/issues/1778
      execute('autoreconf', 'autoreconf -fi')
      super
    end
  end
  recipe.cook
  recipe.activate
  $LIBPATH = ["#{recipe.path}/lib"] | $LIBPATH # rubocop:disable Style/GlobalVars
  $CPPFLAGS << " -I#{recipe.path}/include" # rubocop:disable Style/GlobalVars
end

abort 'libjq not found' unless have_library('jq')

create_makefile('jq_core')
