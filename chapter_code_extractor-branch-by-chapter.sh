#!/usr/bin/env bash

ROOT_FOLDER="../package-based-rails-applications"
CM=$2

if [ "$1" == "FRESH" ]; then
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

    if [ "$1" == "FRESH" ]; then
      echo ""
    else
      BASE_BRANCH=$BRANCH_NAME
    fi

    COMMIT_MESSAGE=$CM

    sleep 1

    pushd $ROOT_FOLDER && git checkout $BASE_BRANCH && git checkout -b $BRANCH_NAME; git checkout $BRANCH_NAME && popd

    echo "extractChapter for SRC $SRC"

    rm -rf $ROOT_FOLDER/*
    FILE=$(find docker/minio/data/releases/$NAME* | sort | tail -1)
    tar -C $ROOT_FOLDER -xzf $FILE 

    if [ -z "$COMMIT_MESSAGE" ]; then
        COMMIT_MESSAGE="Content for $BRANCH_NAME (`date +'%Y-%m-%d'`)"
    fi

    pushd $ROOT_FOLDER && \
      mv sportsball/* . && mv sportsball/.* . ; \
      rm -rf sportsball && \
      git add . && \
      git commit -m "$COMMIT_MESSAGE" ; \
      git checkout main && \
      git clean -fd && git checkout . && \
      popd
}



extractChapter "main" "main"
extractChapter "c2s01" "main"
extractChapter "c2s02" "c2s01"
extractChapter "c2s03" "c2s02"
extractChapter "c2s04" "c2s03"
extractChapter "c2s05" "c2s04"
extractChapter "c2s06" "c2s05"

extractChapter "c3s01" "c2s06"
extractChapter "c3s02" "c2s06"
extractChapter "c3s03" "c4s02"

extractChapter "c5s07-1" "c2s06"
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
extractChapter "c7s01" "c6s04-2b"
