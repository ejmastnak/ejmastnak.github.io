#!/bin/bash
# NAME
#    update-date - updates the last-modified date of web pages
#
# SYNOPSIS
#     update-date directory

cd "${1}"
for file in *.md; do

  date_last_mod=`date --reference=${file} "+%Y-%m-%d %H:%M:%S %z"`

  sed -i "s/^date_last_mod: .*$/date_last_mod: ${date_last_mod}/" ${file}

done
