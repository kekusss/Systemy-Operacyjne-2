#!/bin/bash -eu

pushd groovies

FILES=$(ls)

# We wszystkich plikach w katalogu 'groovies' zamień $HEADER$ na /temat/
for FILE in $FILES; do
    sed -ri 's/\$HEADER\$/\/temat\//g' ${FILE}
done

# We wszystkich plikach w katalogu 'groovies' po każdej linijce z 'class' dodać '  String marker = '/!@$%/''
for FILE in $FILES; do
    sed -ri  '/class/a String marker = "\/!@\$%\/"' ${FILE}
done

# We wszystkich plikach w katalogu 'groovies' usuń linijki zawierające frazę 'Help docs:'
for FILE in $FILES; do
    sed -ri  '/Help docs:/d' ${FILE}
done
