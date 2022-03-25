#!/bin/sh
file="test.tex"
lines=4
font_size="large"
geometry=`sh "../resources/geometry.sh" ${lines}`

sh "../resources/font-big.sh"
sh "../resources/start-screenkey.sh" "${geometry}" "${font_size}" &

# Open Vim to edit the demonstration file 
nvim -c "Goyo" \
     -c "set number" \
  ${file}

# Close screenkey after Vim closes
kill $(pgrep screenkey)

# Reset font to normal size
sh "../resources/font-small.sh"
