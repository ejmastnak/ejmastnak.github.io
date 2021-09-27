#!/bin/bash
# Usage fmf-transfer [document-keys]
# EXAMPLE usage: 
# fmf-transfer.sh  # (applies to all keys in include.txt)
# fmf-transfer.sh emp-lecture
# fmf-transfer.sh emp-exercises emp-lecture

# document-key should be a valid key name of a dictionary entry in database.yml
# EXAMPLE database.yml entry:
# emp-lecture:
#   fmf-path: "year3/emp/emp-lecture/emp-lecture.pdf"
#   site-path: "year3/emp/emp-lecture.pdf"

# EXAMPLE yq query:
# yq e ".emp-lecture.fmf-path" database.yml

FMF_PATH="../../../academics/fmf/"

function copy_file() {
  # arg1: full path to source
  # arg2: full path to target
  if cp "${1}" "${2}"
  then
    echo "Success: copied ${FMF_PATH}${path_relto_fmf} to ${path_relto_site}"
  else
    echo "ERROR: failed to copy ${FMF_PATH}${path_relto_fmf} to ${path_relto_site}"
  fi
}

# COPY ALL FILES
if [ "$#" == 0 ]
then
  while read key  # read through all lines in include.txt
  do
    [[ -z "$key" ]] && continue    # skip blank lines
    [[ $key = \#* ]] && continue  # skip commented lines
    echo "$key"
    path_relto_fmf="$(yq eval ".${key}.fmf-path" database.yml)"
    path_relto_site="$(yq eval ".${key}.site-path" database.yml)"
    copy_file "${FMF_PATH}${path_relto_fmf}" "${path_relto_site}"
    echo ""
  done <include.txt
# --------------------------- #

# COPY SPECIFIED FILES
else
  for key in "$@"
  do
    path_relto_fmf="$(yq eval ".${key}.fmf-path" database.yml)"
    path_relto_site="$(yq eval ".${key}.site-path" database.yml)"

    # test for invalid key in which case the yq query returns the string "null"
    if [ ${path_relto_fmf} == "null" ] || [ ${path_relto_site} == "null" ]
    then
      echo "Invalid key: ${key}"
      exit 2
    fi
    echo "${key}"
    copy_file "${FMF_PATH}${path_relto_fmf}" "${path_relto_site}"
    echo ""
  done
fi
# --------------------------- #

# # EXIT
# else
#   >&2 echo "Illegal number of parameters."
#   exit 2
# fi

