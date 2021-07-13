#!/usr/bin/env bash

set -v
set -x
set -e

pwd

mkdir -f gems
export GEM_HOME=`pwd`/gems

apt-get -y update
apt-get -y install ack graphviz

gem install bundler -v 2.2.5

tar -xzf code_input/$PREV_CHAPTER*.tgz -C code_output

cd code_output/sportsball

../../generator-scripts-repo/generator_scripts/generators/$CHAPTER.sh

cd ..
tar --exclude='tmp/*' --exclude='gems/*' -zcf $CHAPTER-`date +%Y%m%d%H%M%S`.tgz sportsball; echo "zipping done"