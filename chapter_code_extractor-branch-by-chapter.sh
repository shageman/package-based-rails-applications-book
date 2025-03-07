#!/usr/bin/env bash

set -e
set -x

ROOT_FOLDER="../package-based-rails-applications"
CM=$2

IS_FRESH=$([ "$1" == "FRESH" ] && echo "true" || echo "false")

if [ "$IS_FRESH" == "true" ]; then
    rm -rf $ROOT_FOLDER
    mkdir $ROOT_FOLDER
    pushd $ROOT_FOLDER && git init && touch README && git add . && git commit -m "Initial commit" && popd
fi

extractChapter () {
    NAME=$1
    BRANCH_NAME=$NAME
    BASE_BRANCH=$2

    if [ "$BRANCH_NAME" == "main" ]; then
        NAME="app"
    fi

    if [ "$IS_FRESH" == "true" ]; then
      echo "BRANCHING: Fresh setup, branching from base branch. $BASE_BRANCH"
      git checkout $BASE_BRANCH
      git pull --rebase
      git checkout -b $BRANCH_NAME
    elif ! git ls-remote --exit-code --heads origin $BRANCH_NAME; then
      echo "BRANCHING: Branch $BRANCH_NAME does not exist remotely"
      git checkout $BASE_BRANCH
      git pull --rebase || echo "can't pull base branch $BASE_BRANCH"
      git checkout -b $BRANCH_NAME
    elif ! git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
      echo "BRANCHING: Branch $BRANCH_NAME does not exist locally"
      BASE_BRANCH=$BRANCH_NAME
      git checkout $BASE_BRANCH
      git pull --rebase
      git checkout $BRANCH_NAME
    else
      echo "BRANCHING."
      BASE_BRANCH=$BRANCH_NAME
      git checkout $BASE_BRANCH
      git pull --rebase
      git checkout $BRANCH_NAME
    fi

    COMMIT_MESSAGE=$CM

    sleep 1

    echo "extractChapter for SRC $SRC"

    FILE=$(find "$ROOT_FOLDER-book/docker/minio/data/releases/$NAME"* | sort | tail -1)
    if [ -z "$FILE" ]; then
        echo "ERROR: File not found for $NAME"
        exit 1
    fi
    rm -rf $ROOT_FOLDER/*
    tar -C $ROOT_FOLDER -xzf $FILE 

    if [ -z "$COMMIT_MESSAGE" ]; then
        COMMIT_MESSAGE="Content for $BRANCH_NAME (`date +'%Y-%m-%d'`)"
    fi

    rm -rf sportsball/.bundle
    rm -rf sportsball/.github
    rm -rf sportsball/.git
    mv sportsball/* . && mv sportsball/.* .
    rm -rf sportsball

    echo '
# Source Code to _Package-Based Rails Applications_ by Stephan Hagemann

This repository holds the source code used in my book on [Package-based Rails Applications](https://stephanhagemann.com/books/gradual-modularization). The main repository is available at <https://github.com/shageman/package-based-rails-applications-book>. This repository holds all the chapter code in separate branches so that the diffs between versions are more visible.

Because the Ruby and Rails ecosystems are moving so rapidly, creating a book about high-level structural concepts is
tough when underlying libraries constantly require subtle changes to the sample code. To this end, all source code packages its gem dependencies.
    ' > README.md
    git add .
    echo "Press 'c' to continue..."
    while : ; do
        read -n 1 k <&1
        if [[ $k = c ]] ; then
            echo ""
            echo "Continuing..."
            break
        fi
    done
    git commit -m "$COMMIT_MESSAGE" || echo "No changes to commit for $BRANCH_NAME"
    git checkout main
    git clean -fd && git checkout .
}

pushd $ROOT_FOLDER

extractChapter "main" "main"
extractChapter "c2s01" "main"
extractChapter "c2s02" "c2s01"
extractChapter "c2s03" "c2s02"
extractChapter "c2s04" "c2s03"
extractChapter "c2s05" "c2s04"
extractChapter "c2s06" "c2s05"
extractChapter "c2s07" "c2s06"

extractChapter "c4s01" "c2s07"
extractChapter "c4s02" "c4s01"
extractChapter "c4s03" "c4s02"
extractChapter "c4s04" "c4s03"
extractChapter "c4s05" "c4s03"
extractChapter "c4s06" "c4s05"
extractChapter "c4s07" "c4s06"
extractChapter "c4s08" "c4s07"

extractChapter "c5s07-1" "c4s07"
extractChapter "c5s07-2" "c5s07-1"
extractChapter "c5s07-3" "c5s07-2"
extractChapter "c5s08" "c5s07-3"
extractChapter "c5s09" "c5s08"

extractChapter "c6s01" "c5s07-3"
extractChapter "c6s02" "c6s01"
extractChapter "c6s03" "c6s02"
extractChapter "c6s04-1" "c6s03"
extractChapter "c6s04-2a" "c6s03"
extractChapter "c6s04-2b" "c6s04-2a"

extractChapter "c9s01-a" "c5s07-3"
extractChapter "c9s01-b" "c5s07-3"

extractChapter "c9s02" "c5s07-3"

popd
