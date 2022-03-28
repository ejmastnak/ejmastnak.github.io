#!/bin/sh
input="derivative"
W="1700"
H="500"

gifski -W ${W} -H ${H} "${input}.mp4" --output "${input}.gif"

# Count number of frames in original GIF
last_frame=$(identify "${input}.gif" | wc -l)
last_frame=$((last_frame-1))  # because frames are 0-indexed

gifsicle --colors 256 "${input}.gif" "#0-${last_frame}" -O3 > "${input}-tmp.gif"

rm "${input}.gif"
mv "${input}-tmp.gif" "${input}.gif"
