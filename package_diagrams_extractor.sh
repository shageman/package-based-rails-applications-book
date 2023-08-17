#!/usr/bin/env bash

copyPackageDiagram () {
    SRC=$1
    OUT=$2

    if [ -z $SRC ];
        then echo "ERROR: call copyPackageDiagram as copyPackageDiagram(SRC[, OUT])"
        exit 1
    fi

    echo "copyPackageDiagram for SRC $SRC"

    if [ -z $OUT ]; then
        echo "copyPackageDiagram called without OUT. Setting OUT to SRC ($SRC)"
        OUT=$SRC
    fi

    mkdir ../book/manuscript/resources/package_diagrams/$OUT
    cp $SRC/sportsball/diagrams/*.png ../book/manuscript/resources/package_diagrams/$OUT/
}

rm -rf ../book/manuscript/resources/package_diagrams
mkdir -p ../book/manuscript/resources/package_diagrams

for i in $(ls -1 -d c*/ | sed 's/.$//'); do
    copyPackageDiagram "$i" "$i"
done
