#!/bin/bash

SOURCE_DIR=${1:-lab_uno}
RM_LIST=${2:-lab_uno/2remove}
TARGET_DIR=${3:-bakap}

if ! [[ -d "$TARGET_DIR" ]]; then
    mkdir $TARGET_DIR
fi

REMOVE_LIST=$(cat ${RM_LIST})
for ITEM in ${REMOVE_LIST}; do
    if [[ -f "${SOURCE_DIR}/${ITEM}" ]]; then
        rm ${SOURCE_DIR}/${ITEM}
    fi
    if [[ -d "${SOURCE_DIR}/${ITEM}" ]]; then
        rm -r ${SOURCE_DIR}/${ITEM}
    fi
done

CAT_LIST=$(ls ${SOURCE_DIR})

for ITEM in ${CAT_LIST}; do
    if [[ -f "${SOURCE_DIR}/${ITEM}" ]]; then
        mv ${SOURCE_DIR}/${ITEM} ${TARGET_DIR}/${ITEM}
    fi

    if [[ -d "${SOURCE_DIR}/${ITEM}" ]]; then
        cp -r ${SOURCE_DIR}/${ITEM} ${TARGET_DIR}/${ITEM}
    fi
done

NUM_FILES=$(ls ${SOURCE_DIR} | wc -w )
if [[ ${NUM_FILES} -gt 0 ]]; then
    echo "jeszcze coś zostało"
    
    if [[ ${NUM_FILES} -ge 2 ]]; then
        echo "zostały co najmniej 2 pliki"

        if [[ ${NUM_FILES} -gt 4 ]]; then
            echo "zostało więcej niż 4 pliki"
        fi

        if [[ ${NUM_FILES} -le 4 ]]; then
            echo "zostało nie więcej niż 4 pliki"
        fi
    fi
else
    echo "tu był Kononowicz"
fi

TARGET_LIST=$(ls ${TARGET_DIR})
for ITEM in $TARGET_LIST; do
    chmod -w ${TARGET_DIR}/${ITEM}
done

DATE=$(date +'%Y-%m-%d')
zip -r bakap_${DATE}.zip ${TARGET_DIR}