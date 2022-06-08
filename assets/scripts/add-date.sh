#!/bin/bash
# NAME
#     add-date - adds date created and date modified to Git-controlled files
#
# SYNOPSIS
#     add-date directory

cd "${1}"
for file in *.md; do

  date=`git log --follow --format=%ad --date iso ${file} | tail -1`
  date_last_mod=`date --reference=${file} "+%Y-%m-%d %H:%M:%S %z"`
  > "${file}.tmp"

  in_frontmatter=0
  # Note the need to set IFS to an empty string to perserve leading white space
  # And to use read -r to perserve backlashes
  # See e.g. https://stackoverflow.com/a/26971716
  while IFS= read -r line
  do
    if [ "${line}" == "---" ]; then
      if [ ${in_frontmatter} -gt 0 ]; then
        echo "date: ${date}" >> "${file}.tmp"
        echo "date_last_mod: ${date_last_mod}" >> "${file}.tmp"
        in_frontmatter=0
      else
        in_frontmatter=1
      fi
    fi
    echo "${line}" >> "${file}.tmp"
  done < "${file}"

  rm "${file}"
  mv "${file}.tmp" "${file}"

done
