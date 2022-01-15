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

extractChapter "c2s01" "c2s01"
extractChapter "c2s02" "c2s02"
extractChapter "c2s03" "c2s03"
extractChapter "c2s04" "c2s04"
extractChapter "c2s05" "c2s05"
extractChapter "c2s06" "c2s06"

extractChapter "c4s01" "c4s01"
extractChapter "c4s02" "c4s02"
extractChapter "c4s03" "c4s03"

extractChapter "c5s07-1" "c5s07-1"
extractChapter "c5s07-2" "c5s07-2"
extractChapter "c5s07-3" "c5s07-3"
extractChapter "c5s08" "c5s08"
extractChapter "c5s09" "c5s09"
    
extractChapter "c6s01" "c6s01"
