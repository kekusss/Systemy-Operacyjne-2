#!/bin/bash  -eu

set +u
PATH_ONE=${1}
PATH_TWO=${2}
set -u

#RCs
DIR_NOT_EXIST=10
INCORRECT_NUM_ARGS=11

if ! [[ "$#" -eq "2" ]]; then
    echo "an incorrect number of arguments were supplied"
    exit "${INCORRECT_NUM_ARGS}"
fi

if ! [[ -d "$PATH_ONE" ]]; then
    echo "${PATH_ONE} is not valid path to folder"
    exit "${DIR_NOT_EXIST}"
fi

if ! [[ -d "$PATH_TWO" ]]; then
    echo "${PATH_TWO} is not valid path to folder"
    exit "${DIR_NOT_EXIST}"
fi


FILE_LIST=$(ls ${PATH_ONE})
for ITEM in ${FILE_LIST}; do
    ITEM_BIG=${ITEM^^}

    if [[ -f "${PATH_ONE}/${ITEM}" ]] && ! [[ -L "${PATH_ONE}/${ITEM}" ]]; then
        echo "${PATH_ONE}/${ITEM} is a regular file"
        ln -s "${PATH_ONE}/${ITEM}" "${PATH_TWO}/${ITEM_BIG%%.*}_ln.${ITEM#*.}"
    fi

    if [[ -d "${PATH_ONE}/${ITEM}" ]]; then
        echo "${PATH_ONE}/${ITEM} is a folder"
        ln -s "${PATH_ONE}/${ITEM}" "${PATH_TWO}/${ITEM_BIG%%.*}_ln"
    fi
    
    if [[ -L "${PATH_ONE}/${ITEM}" ]]; then
        echo "${PATH_ONE}/${ITEM} is a symlink"
    fi
done
