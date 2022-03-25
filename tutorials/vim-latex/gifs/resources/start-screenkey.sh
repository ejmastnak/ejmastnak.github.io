#!/bin/sh
# Start screen key in the background
# $1 geometry: an X screen geometry of the form "WxH+X+Y"
# $2 font-size: one of {large, medium, small}
# $3 additional arguments, may be left blank

# Additional arguments passed
if [ ${#} -eq 3 ]
then
  screenkey --geometry "${1}" \
    --font "Source Code Pro Bold" \
    --font-size "${2}" \
    --bg-color "#81a1c1" \
    --font-color "#eceff4" "${3}" &
else
  screenkey --geometry "${1}" \
    --font "Source Code Pro Bold" \
    --font-size "${2}" \
    --bg-color "#81a1c1" \
    --font-color "#eceff4" &
fi

