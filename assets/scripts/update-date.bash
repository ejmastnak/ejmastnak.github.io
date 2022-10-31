#!/bin/bash
# NAME
#    update-date - updates the last-modified date of a Jekyll markdown file.
#
# SYNOPSIS
#     update-date file.md

date_last_mod=`date --reference=${1} "+%Y-%m-%d %H:%M:%S %z"`
sed -i "s/^date_last_mod: .*$/date_last_mod: ${date_last_mod}/" ${1}
