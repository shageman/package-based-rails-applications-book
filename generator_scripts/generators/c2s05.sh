#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step moves all package out of app/packages and into packages/. 
# Collocating specs and app code
#
###############################################################################

mv app/packages .

for PACKAGE in `ls -1 packages`
do
  mkdir packages/$PACKAGE/app
  mkdir packages/$PACKAGE/spec
  [ ! -d packages/$PACKAGE/controllers ] || mv packages/$PACKAGE/controllers packages/$PACKAGE/app
  [ ! -d packages/$PACKAGE/helpers ] || mv packages/$PACKAGE/helpers packages/$PACKAGE/app
  [ ! -d packages/$PACKAGE/models ] || mv packages/$PACKAGE/models packages/$PACKAGE/app
  [ ! -d packages/$PACKAGE/views ] || mv packages/$PACKAGE/views packages/$PACKAGE/app
  [ ! -d packages/$PACKAGE/channels ] || mv packages/$PACKAGE/channels packages/$PACKAGE/app
  [ ! -d packages/$PACKAGE/jobs ] || mv packages/$PACKAGE/jobs packages/$PACKAGE/app
  [ ! -d packages/$PACKAGE/mailers ] || mv packages/$PACKAGE/mailers packages/$PACKAGE/app

  [ ! -d spec/packages/$PACKAGE/helpers ] || mv spec/packages/$PACKAGE/helpers packages/$PACKAGE/spec
  [ ! -d spec/packages/$PACKAGE/models ] || mv spec/packages/$PACKAGE/models packages/$PACKAGE/spec
  [ ! -d spec/packages/$PACKAGE/requests ] || mv spec/packages/$PACKAGE/requests packages/$PACKAGE/spec
  [ ! -d spec/packages/$PACKAGE/routing ] || mv spec/packages/$PACKAGE/routing packages/$PACKAGE/spec
  [ ! -d spec/packages/$PACKAGE/system ] || mv spec/packages/$PACKAGE/system packages/$PACKAGE/spec
  [ ! -d spec/packages/$PACKAGE/views ] || mv spec/packages/$PACKAGE/views packages/$PACKAGE/spec
done

sed -i "/config.eager_load_paths +='/d" config/application.rb
sed -i '/config.eager_load_paths/a\    config.eager_load_paths += Dir.glob("#{root}/packages/*/app/{*,*/concerns}")' config/application.rb


sed -i "/append_view_path/c\  append_view_path(Dir.glob(Rails.root.join('packages\/*\/app\/views')))" packages/rails_shims/app/controllers/application_controller.rb



sed -i '/Adjust RSpec configuration for package folder structure/,+16d' spec/spec_helper.rb

echo "
# Adjust RSpec configuration for package folder structure
RSpec.configure do |config|
  config.define_derived_metadata(file_path: Regexp.new('/packages/.*/spec/controllers')) { |metadata| metadata[:type] = :controller }
  config.define_derived_metadata(file_path: Regexp.new('/packages/.*/spec/models')) { |metadata| metadata[:type] = :model }
  config.define_derived_metadata(file_path: Regexp.new('/packages/.*/spec/requests')) { |metadata| metadata[:type] = :request }
  config.define_derived_metadata(file_path: Regexp.new('/packages/.*/spec/routing')) { |metadata| metadata[:type] = :routing }
  config.define_derived_metadata(file_path: Regexp.new('/packages/.*/spec/system')) { |metadata| metadata[:type] = :system }
  config.define_derived_metadata(file_path: Regexp.new('/packages/.*/spec/views')) { |metadata| metadata[:type] = :view }

  config.before(:each, :type => lambda {|v| v == :view}) do
    Dir.glob(Rails.root + ('packages/*/app/views')).each do |path|
      view.lookup_context.append_view_paths [path]
    end
  end
end
" >> spec/spec_helper.rb



sed -i "s/app\///g" packages/games/package.yml
sed -i "s/app\///g" packages/games_admin/package.yml
sed -i "s/app\///g" packages/prediction_ui/package.yml
sed -i "s/app\///g" packages/teams/package.yml
sed -i "s/app\///g" packages/teams_admin/package.yml
sed -i "s/app\///g" packages/welcome_ui/package.yml

echo '
--default-path packages
-I spec
' >> .rspec

echo "pack_paths:
- packages/*
- .
" > packs.yml