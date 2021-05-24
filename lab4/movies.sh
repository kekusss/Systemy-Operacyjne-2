#!/bin/bash -eu

# + 1.0: shellcheck nie krzyczy.

# + 0.5: Dotyczy opcji ‘-f’: jeżeli plik podany przez użytkownika nie posiada rozszerzenia '.txt' dodaj je
function repair_extension () {
    EXT=".${FILE_4_SAVING_RESULTS##*.}"
    if [[ "${EXT}" != ".txt" ]]; then
        FILE_4_SAVING_RESULTS="${FILE_4_SAVING_RESULTS}.txt"
    fi
}

function print_help () {
    echo "This script allows to search over movies database"
    echo -e "-d DIRECTORY\n\tDirectory with files describing movies"
    echo -e "-a ACTOR\n\tSearch movies that this ACTOR played in"
    echo -e "-t QUERY\n\tSearch movies with given QUERY in title"
    echo -e "-f FILENAME\n\tSaves results to file (default: results.txt)"
    echo -e "-R REGEX STORY Search\n\tSearch movies which story matches given regex"
    echo -e "-y YEAR\n\tSearch movies that were released after given year"
    echo -e "-i\n\tTurns off case sensitivity. Work with REGEX search (-R)"
    echo -e "-x\n\tPrints results in XML format"
    echo -e "-h\n\tPrints this help message"
}

function print_error () {
    echo -e "\e[31m\033[1m${*}\033[0m" >&2
}

function get_movies_list () {
    local -r MOVIES_DIR=${1}
    local -r MOVIES_LIST=$(cd "${MOVIES_DIR}" && realpath ./*)
    echo "${MOVIES_LIST}"
}

function query_title () {
    # Returns list of movies from ${1} with ${2} in title slot
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if grep "| Title" "${MOVIE_FILE}" | grep -q "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

function query_actor () {
    # Returns list of movies from ${1} with ${2} in actor slot
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        if grep "| Actors" "${MOVIE_FILE}" | grep -q "${QUERY}"; then
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

# + 1.0: Dodaj wyszukiwanie po polu z fabułą, za pomocą wyrażenia regularnego. Np. -R 'Cap.*Amer' Jeżeli dodatkowo podamy parametr '-i' to ignoruje wielkość liter
function query_story () {
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do        
        if [[ "${CASE_SENSITIVE}" = true ]]; then            
            if grep "| Plot" "${MOVIE_FILE}" | grep -qE "${QUERY}"; then
                RESULTS_LIST+=( "${MOVIE_FILE}" )
            fi
        else
            if grep "| Plot" "${MOVIE_FILE}" | grep -qiE "${QUERY}"; then
                RESULTS_LIST+=( "${MOVIE_FILE}" )
                
            fi
        fi
    done
   echo "${RESULTS_LIST[@]:-}"
}

# + 1.0: Dodaj opcję -y ROK: wyszuka wszystkie filmy nowsze niż ROK. Pamiętaj o dodaniu opisu do -h
function query_year () {
    local -r MOVIES_LIST=${1}
    local -r QUERY=${2}

    local RESULTS_LIST=()
    for MOVIE_FILE in ${MOVIES_LIST}; do
        YEAR="$(grep "| Year" "${MOVIE_FILE}" | cut -d':' -f2)"        
        if [[ YEAR -gt ${QUERY} ]]; then           
            RESULTS_LIST+=( "${MOVIE_FILE}" )
        fi
    done
    echo "${RESULTS_LIST[@]:-}"
}

# + 1.0: Dokończ funkcję “print_xml_format”
function print_xml_format () {
    local -r FILENAME=${1}

    local TEMP
    TEMP=$(cat "${FILENAME}")

    # replace send line to <movie>
    TEMP=$(echo "${TEMP}" | sed -r '2 s/^.*$/<movie>/')

    # change 'Author:' into <Author> & others too
    TEMP="${TEMP//| Author: /<Author>}"
    TEMP="${TEMP//| Title: /<Title>}"
    TEMP="${TEMP//| Year: /<Year>}"
    TEMP="${TEMP//| Runtime: /<Runtime>}"
    TEMP="${TEMP//| IMDB: /<IMDB>}"
    TEMP="${TEMP//| Tomato: /<Tomato>}"
    TEMP="${TEMP//| Rated: /<Rated>}"
    TEMP="${TEMP//| Genre: /<Genre>}"
    TEMP="${TEMP//| Director: /<Director>}"
    TEMP="${TEMP//| Actors: /<Actors>}"
    TEMP="${TEMP//| Plot: /<Plot>}"

    # append tag after lines 3-12
    TEMP=$(echo "${TEMP}" | sed -r '3,12s/([A-Za-z]+).*/\0<\/\1>/')

    # replace the last line with </movie>
    TEMP=$(echo "${TEMP}" | sed '$s/===*/<\/movie>/')

    echo "${TEMP}"
}

function print_movies () {
    local -r MOVIES_LIST=${1}
    local -r OUTPUT_FORMAT=${2}

    for MOVIE_FILE in ${MOVIES_LIST}; do
        if [[ "${OUTPUT_FORMAT}" == "xml" ]]; then
            print_xml_format "${MOVIE_FILE}"
        else
            cat "${MOVIE_FILE}"
        fi
    done
}

# is -d used init
HAS_DIR=false
# is -i used init
CASE_SENSITIVE=true

while getopts ":hd:t:a:f:x:R:y:i" OPT; do
  case ${OPT} in
    h)
        print_help
        exit 0
        ;;
    d)
        MOVIES_DIR=${OPTARG}
        HAS_DIR=true
        ;;
    t)
        SEARCHING_TITLE=true
        QUERY_TITLE=${OPTARG}
        ;;
    f)
        FILE_4_SAVING_RESULTS=${OPTARG}
        repair_extension
        ;;
    a)
        SEARCHING_ACTOR=true
        QUERY_ACTOR=${OPTARG}
        ;;
    x)
        OUTPUT_FORMAT="xml"
        ;;
    R)
        SEARCHING_STORY=true
        QUERY_STORY=${OPTARG}
        ;;
    y)
        SEARCHING_YEAR=true
        QUERY_YEAR=${OPTARG}
        ;;
    i)
        CASE_SENSITIVE=false
        ;;
    \?)
        print_error "ERROR: Invalid option: -${OPTARG}"
        exit 1
        ;;
  esac
done

# + 0.5: Dodaj sprawdzenie, czy na pewno wykorzystano opcję '-d' i czy jest to katalog
# check if -d switch is used
if [[ "$HAS_DIR" == false ]]; then
    echo "Enter a directory. You can do this with the -d switch."
    exit 1
fi

# check if MOVIES_DIR arg is directory
if [[ ! -d ${MOVIES_DIR} ]]; then
    echo "The file with the given name is not a directory. Please enter a valid directory."
    exit 1
fi

MOVIES_LIST=$(get_movies_list "${MOVIES_DIR}")

if ${SEARCHING_TITLE:-false}; then
    MOVIES_LIST=$(query_title "${MOVIES_LIST}" "${QUERY_TITLE}")
fi

if ${SEARCHING_ACTOR:-false}; then
    MOVIES_LIST=$(query_actor "${MOVIES_LIST}" "${QUERY_ACTOR}")
fi

if ${SEARCHING_STORY:-false}; then
    MOVIES_LIST=$(query_story "${MOVIES_LIST}" "${QUERY_STORY}" "${CASE_SENSITIVE}")
fi

if ${SEARCHING_YEAR:-false}; then
    MOVIES_LIST=$(query_year "${MOVIES_LIST}" "${QUERY_YEAR}")
fi

if [[ "${#MOVIES_LIST}" -lt 1 ]]; then
    echo "Found 0 movies :-("
    exit 0
fi

if [[ "${FILE_4_SAVING_RESULTS:-}" == "" ]]; then
    print_movies "${MOVIES_LIST}" "${OUTPUT_FORMAT:-raw}"
else
    # TODO: add XML option
    print_movies "${MOVIES_LIST}" "raw" | tee "${FILE_4_SAVING_RESULTS}"
fi
