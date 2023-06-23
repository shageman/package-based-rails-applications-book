#!/usr/bin/env bash

# INSTALL https://min.io/docs/minio/linux/reference/minio-mc.html?ref=docs

# brew install minio/stable/mc

# bash +o history
# mc alias set minio concourse-server.local:9001 minio minio123
# bash -o history

# mc alias set concourse-server http://concourse-server.local:9001 minio minio123


extractChapter () {
    CHAPTER=$1

    if [ -z $CHAPTER ];
        then echo "ERROR: call extractChapter as extractChapter(CHAPTER)"
        exit 1
    fi

    echo "extractChapter for CHAPTER $CHAPTER"

    rm -rf $CHAPTER
    mkdir -p $CHAPTER
    FILE=$(mc ls concourse-server/releases/ | grep $CHAPTER | sort | tail -1 | awk '{print $NF}')
    echo $FILE
    echo $CHAPTER/$FILE
    mc cp concourse-server/releases/$FILE $CHAPTER/$FILE
    sleep 1
    tar -xzf $CHAPTER/$FILE -C $CHAPTER
}

extractChapter "c2s01"
extractChapter "c2s02"
extractChapter "c2s03"
extractChapter "c2s04"
extractChapter "c2s05"
extractChapter "c2s06"

extractChapter "c4s01"
extractChapter "c4s02"
extractChapter "c4s03"

extractChapter "c5s07-1"
extractChapter "c5s07-2"
extractChapter "c5s07-3"
extractChapter "c5s08"
extractChapter "c5s09"

extractChapter "c6s01"
extractChapter "c6s02"
extractChapter "c6s03"
extractChapter "c6s04-1"
extractChapter "c6s04-2a"
extractChapter "c6s04-2b"

extractChapter "c7s01"
