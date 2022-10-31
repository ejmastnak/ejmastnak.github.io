#!/bin/bash
# NAME
#    update-all-dates - updates the last-modified date of all web pages for
#    it is relevant in this website.
#
# SYNOPSIS
#     bash update-all-dates

root_dir="../.."
update_date_script="${root_dir}/assets/scripts/update-date.bash"

declare -a arr=(\
  "tutorials" \
  "projects" \
  "fmf-course-pages")

# for dir in "${arr[@]}"; do
#   find "${root_dir}/${dir}" -name "*.md" | while read -r file ; do
#       bash "${update_date_script}" "${file}"
#   done
# done

# Root dir
for file in "${root_dir}/"*.md; do
    if [[ ! -e "${file}" ]]; then continue; fi
    bash "${update_date_script}" "${file}"
done
