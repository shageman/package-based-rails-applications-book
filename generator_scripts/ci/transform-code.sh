#!/usr/bin/env bash

set -v
set -x
set -e

apt-get -y update
apt-get -y install ack graphviz

gem install bundler -v 2.2.5

tar -xzf code_input/$PREV_CHAPTER*.tgz -C code_output

cd code_output/sportsball

../../generator-scripts-repo/generator_scripts/generators/$CHAPTER.sh

cd ..
tar --exclude='tmp/*' -zcf $CHAPTER-`date +%Y%m%d%H%M%S`.tgz sportsball; echo "zipping done"