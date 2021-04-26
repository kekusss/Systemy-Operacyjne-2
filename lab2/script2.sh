#!/bin/bash  -eu

set +u
FOLDER=${1}
FILE=${2}
set -u

#RCs
DIR_NOT_EXIST=10
INCORRECT_NUM_ARGS=11

if ! [[ "$#" -eq "2" ]]; then
    echo "an incorrect number of arguments were supplied"
    exit "${INCORRECT_NUM_ARGS}"
fi

if ! [[ -d "$FOLDER" ]]; then
    echo "${FOLDER} is not valid path to folder"
    exit "${DIR_NOT_EXIST}"
fi

if ! [[ -f "$FILE" ]]; then
    echo "${FILE} is not valid path to regular file"
    exit "${DIR_NOT_EXIST}"
fi


FILE_LIST=$(ls ${FOLDER})

DATE=$(date +'%Y-%m-%d')

for ITEM in ${FILE_LIST}; do
    if [[ -L "${FOLDER}/${ITEM}" ]] && [[ ! -e "${FOLDER}/${ITEM}" ]] ; then
        rm "${FOLDER}/${ITEM}"
        echo ${DATE} : ${ITEM} $'\n' >> ${FILE}
    fi
done
