#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step adds a gem (== a component) and adds zeitwerk compatible load dirs
# and adds an enginification mechanism to allow this gem to a packwerk package
#
###############################################################################

bundle install --local

sed -i "/spec.require_paths/a\\  spec.add_development_dependency 'zeitwerk'" testgem/testgem.gemspec



sed -i "/require_relative '..\/app\/services\/testgem\/sample'/d" testgem/lib/testgem.rb
sed -i "/frozen_string_literal/a\ \n\
if defined?(Rails)\n\
  require 'testgem/engine'\n\
else\n\
  require 'zeitwerk'\n\
  loader = Zeitwerk::Loader.new\n\
  loader.tag = File.basename(__FILE__, '.rb')\n\
  loader.inflector = Zeitwerk::GemInflector.new(__FILE__)\n\
  app_paths = Dir.glob(File.expand_path(File.join(__dir__, '../app', '/*')))\n\
  app_paths.each { |k| loader.push_dir(k) }\n\
  loader.setup\n\
end
" testgem/lib/testgem.rb

cat testgem/lib/testgem.rb

echo "module Testgem
  class Engine < ::Rails::Engine
    isolate_namespace Testgem
  end
end" > testgem/lib/testgem/engine.rb

cd testgem
bundle
rake spec
cd ..

echo 'enforce_dependencies: true' > testgem/package.yml
