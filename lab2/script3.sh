#!/bin/bash  -eu

set +u
FOLDER=${1}
set -u

#RCs
DIR_NOT_EXIST=10
INCORRECT_NUM_ARGS=11

if ! [[ "$#" -eq "1" ]]; then
    echo "an incorrect number of arguments were supplied"
    exit "${INCORRECT_NUM_ARGS}"
fi

if ! [[ -d "$FOLDER" ]]; then
    echo "${FOLDER} is not valid path to folder"
    exit "${DIR_NOT_EXIST}"
fi


FILE_LIST=$(ls ${FOLDER})
pushd ${FOLDER}

for ITEM in ${FILE_LIST}; do
    if [[ -f "${ITEM}" ]] && ! [[ -L "${ITEM}" ]] && [[ ${ITEM#*.} == "bak" ]] ; then
        chmod "uo-w" ${ITEM}
    fi

    if [[ -d "${ITEM}" ]] && [[ ${ITEM#*.} == "bak" ]] ; then
        chmod "ug-x" ${ITEM}
    fi

    if [[ -d "${ITEM}" ]] && [[ ${ITEM#*.} == "tmp" ]] ; then
        chmod -R "u+wx" ${ITEM}
    fi

    if [[ -f "${ITEM}" ]] && [[ ${ITEM#*.} == "txt" ]] ; then
        chmod 421 ${ITEM}
    fi

    if [[ -f "${ITEM}" ]] && [[ ${ITEM#*.} == "exe" ]] ; then
        chmod "a+x" ${ITEM}
    fi
done
