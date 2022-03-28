#!/bin/sh
# Goal: convert mpv videos, which are oddly-sized 1700x500, to 1920x1080 by adding a border

pad_color="fbfbfc"   # PDF bg

W_in=1700
H_in=500
W_out=1920
H_out=1080
X_diff=$((W_out-W_in))
Y_diff=$((H_out-H_in))
X_pad=$((X_diff/2))
Y_pad=$((Y_diff/2))

FILES="*.mp4"
for f in $FILES
do
	base="${f%%.mp4}"
	echo "${base}"
  input="${base}.mp4"
  output="${base}-padded.mp4"
  ffmpeg -y -i "${input}" -filter_complex "[0]pad=w=${X_diff}+iw:h=${Y_diff}+ih:x=${X_pad}:y=${Y_pad}:color=${pad_color},format=rgb24" "${output}"
done
