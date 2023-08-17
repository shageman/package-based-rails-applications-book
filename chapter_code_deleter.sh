#!/usr/bin/env bash

set -e

FILES=`mc ls concourse-server/releases/ | grep -v app | awk '{print $NF}'`
# printf '%s\n' "${FILES[@]}"

CHAPTERS=`printf '%s\n' "${FILES[@]}" | awk 'BEGIN{FS=OFS="-"}{NF--; print}' | sort -u`
# printf '%s\n' "${CHAPTERS[@]}"

FILES_TO_KEEP=()
for CHAPTER in $CHAPTERS
do
  LAST_FILE_FOR_CHAPTER=$(mc ls concourse-server/releases/ | grep $CHAPTER | sort | tail -1 | awk '{print $NF}')
  FILES_TO_KEEP+=($LAST_FILE_FOR_CHAPTER)
done
# printf '%s\n' "${FILES_TO_KEEP[@]}"

for F in ${FILES[@]}
do
  if [[ "${FILES_TO_KEEP[@]}" == *"$F"* ]]; then
    echo "Keep $F"
  else
    echo "Delete $F: 'mc rm concourse-server/releases/$F'"

    if [ "$1" == "DELETE" ]
    then
      mc rm concourse-server/releases/$F
    fi
  fi
done

