#!/bin/bash -eu

# Znajdź w pliku access_log zapytania, które mają frazę "denied" w linku
cat access_log | cut -d' ' -f7 | grep \/denied

# Znajdź w pliku access_log zapytania typu POST
cat access_log | cut -d' ' -f6,7 | grep \"POST

# Znajdź w pliku access_log zapytania wysłane z IP 64.242.88.10
cat access_log | cut -d' ' -f1,6,7,8 | grep "64\.242\.88\.10 "

# Znajdź w pliku access_log zapytania NIEWYSŁANE z adresu IP tylko z FQDN
cat access_log | grep -vE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -f6,7,8

# Znajdź w pliku access_log unikalne zapytania typu DELETE
cat access_log | grep \"DELETE | cut -d" " -f6,7,8 | sort -u

# Znajdź unikalnych 10 adresów IP w access_log
cat access_log | grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | uniq | sed 10q