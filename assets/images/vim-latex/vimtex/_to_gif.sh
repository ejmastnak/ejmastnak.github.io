#!/bin/sh
input="obj-env-item"

# Count number of frames in original GIF
last_frame=$(identify "${input}.gif" | wc -l)
last_frame=$((last_frame-1))  # because frames are 0-indexed

gifsicle --colors 256 "${input}.gif" "#0-${last_frame}" -O3 > "${input}-tmp.gif"

rm "${input}.gif"
mv "${input}-tmp.gif" "${input}.gif"
