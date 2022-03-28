#!/bin/sh
input="fourier"
output="${input}-trimmed"
ext=".mp4"
start_time="00:00:02.500"
end_time="00:00:14.500"

# Unfortunately, decoding and recoding seems
# to be needed for millisecond-accurate times.
ffmpeg -i "${input}${ext}" -ss ${start_time} -to ${end_time} -an -y "${output}${ext}"
