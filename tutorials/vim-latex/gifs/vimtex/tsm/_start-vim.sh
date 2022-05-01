#!/bin/sh
lines=3
font_size="large"
geometry=`sh "../../resources/geometry.sh" ${lines}`

# Temporarily increase font size
sh "../../resources/font-big.sh"

# Start screenkey
sh "../../resources/start-screenkey.sh" "${geometry}" "${font_size}" &

# Set initial file contents
cat template.tex > record.tex

# Open Vim to edit the demonstration file 
nvim -c "source _config.vim" record.tex

# Close screenkey after Vim closes
kill $(pgrep screenkey)

# Reset font to normal size
sh "../../resources/font-small.sh"
