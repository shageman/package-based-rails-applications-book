#!/usr/bin/env bash

extractChapter () {
    SRC=$1
    OUT=$2

    if [ -z $SRC ];
        then echo "ERROR: call extractChapter as extractChapter(SRC[, OUT])"
        exit 1
    fi

    echo "extractChapter for SRC $SRC"

    if [ -z $OUT ]; then
        echo "extractChapter called without OUT. Setting OUT to SRC ($SRC)"
        OUT=$SRC
    fi

    rm -rf $OUT
    mkdir -p $OUT
    FILE=$(find docker/minio/data/releases/$SRC* | sort | tail -1)
    tar -xzf $FILE -C $OUT
}

extractChapter "c2s01" "../code_public/c2s01"
extractChapter "c2s02" "../code_public/c2s02"
extractChapter "c2s03" "../code_public/c2s03"
extractChapter "c2s04" "../code_public/c2s04"
extractChapter "c2s05" "../code_public/c2s05"

