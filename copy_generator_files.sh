#!/usr/bin/env bash

set -e
set -x

cp -R generator_scripts/ ../package-based-rails-applications-book/generator_scripts/

find . -maxdepth 1 -type f | grep -v gitignore | xargs -I {} cp {} ../package-based-rails-applications-book

find ./docker/minio/data/releases -iname "app*" | xargs -I {} cp {} ../package-based-rails-applications-book/docker/minio/data/releases
