#!/bin/bash

set -v
set -x
set -e

###############################################################################
#
# This step adds a gem (with an engine) into the app (== a component) and adds 
# it as a package
#
###############################################################################

bundle install --local

rails plugin new testengine \
  --full \
  --mountable

rm -rf testengine/.git
rm -rf testengine/.gitignore



sed -i "/spec.metadata\[.homepage_uri.\]/d" testengine/testengine.gemspec
sed -i "/spec.metadata\[.source_code_uri.\]/d" testengine/testengine.gemspec
sed -i "/spec.metadata\[.changelog_uri.\]/d" testengine/testengine.gemspec
sed -i "/allowed_push_host/c\  spec.metadata['allowed_push_host'] = 'http://nowhere.atall'" testengine/testengine.gemspec
sed -i "s/TODO: //g" testengine/testengine.gemspec
sed -i "s/TODO//g" testengine/testengine.gemspec



echo 'enforce_dependencies: true' > testengine/package.yml

echo '
package_paths:
- ./packs/*
- .
- testengine
' >> packwerk.yml

sed -i '/pack_paths/a\- ./testengine' packs.yml
