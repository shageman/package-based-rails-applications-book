#!/usr/bin/env bash

set -v
set -x
set -e

# mkdir -p gems
# export GEM_HOME=`pwd`/gems
# export PATH="$GEM_HOME/bin:$PATH"

apt-get -y update
apt-get -y install ack graphviz

gem install bundler -v 2.3.4

tar -xzf code_input/$PREV_CHAPTER*.tgz -C code_output

cd code_output/sportsball

cp VENDORED_GEMS/* vendor/cache/ # get our saved local gems back

../../generator-scripts-repo/generator_scripts/generators/$CHAPTER.sh

find . -iname 'deprecated_references.yml' -delete
bundle install --local
bundle exec packwerk update-deprecations
bin/rake pocky:generate[root]

cd ..
tar --exclude='tmp/*' --exclude='`pwd`/gems/*' -zcf $CHAPTER-`date +%Y%m%d%H%M%S`.tgz sportsball; echo "zipping done"