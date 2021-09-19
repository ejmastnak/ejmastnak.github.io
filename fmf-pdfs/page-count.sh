#!/bin/bash
# Prints the total page count of all pdf files in the fmf-pdfs directory
# Uses qpdf --show-npages file.pdf to get page number
# See fmf-transfer.sh for documentation of the yq query

_VERBOSE=0  # verbose mode; off by default

while getopts "v" OPTION
do
  case $OPTION in
    v) _VERBOSE=1;;
  esac
done

function log() {
    if [[ $_VERBOSE -eq 1 ]]; then
        echo "$@"
    fi
}

total_count=0
while read key  # read through all lines in include.txt
do
  [[ -z "$key" ]] && continue    # skip blank lines
  [[ $key = \#* ]] && continue  # skip commented lines
  path_relto_site="$(yq eval ".${key}.site-path" database.yml)"
  current_pdf_count=$(qpdf --show-npages ${path_relto_site})
  log "${path_relto_site} | Page count: ${current_pdf_count}"
  total_count=$(($total_count + $current_pdf_count))
done <include.txt

echo "Total page count: ${total_count}"
