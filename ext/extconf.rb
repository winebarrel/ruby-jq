# frozen_string_literal: true

require 'mkmf'

def using_system_libraries?
  arg_config('--use-system-libraries', ENV.key?('RUBYJQ_USE_SYSTEM_LIBRARIES'))
end

unless using_system_libraries?
  message "Buildling jq using packaged libraries.\n"

  require 'rubygems'
  require 'mini_portile2'

  onig_recipe = MiniPortile.new('onigmo', '6.2.0')
  onig_recipe.files << 'https://github.com/k-takata/Onigmo/releases/download/Onigmo-6.2.0/onigmo-6.2.0.tar.gz'
  onig_recipe.configure_options = [
    '--disable-static',
    '--disable-maintainer-mode'
  ]
  class << onig_recipe
    def configure
      execute('autoreconf', 'autoreconf -vfi')
      super
    end
  end
  onig_recipe.cook
  onig_recipe.activate
  $LIBPATH = ["#{onig_recipe.path}/lib"] | $LIBPATH # rubocop:disable Style/GlobalVars
  $CPPFLAGS << " -I#{onig_recipe.path}/include" # rubocop:disable Style/GlobalVars

  recipe = MiniPortile.new('jq', '1.6')
  recipe.files = ['https://github.com/stedolan/jq/archive/cff5336ec71b6fee396a95bb0e4bea365e0cd1e8.tar.gz']
  recipe.patch_files << File.join(File.dirname(File.expand_path(__FILE__)), 'jq-onigmo.patch')
  recipe.configure_options = [
    '--disable-static',
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
  $LIBPATH = ["#{onig_recipe.path}/lib", "#{recipe.path}/lib"] | $LIBPATH # rubocop:disable Style/GlobalVars
  $CPPFLAGS << " -I#{recipe.path}/include" # rubocop:disable Style/GlobalVars
end

abort 'libjq not found' unless have_library('jq')

create_makefile('jq_core')
