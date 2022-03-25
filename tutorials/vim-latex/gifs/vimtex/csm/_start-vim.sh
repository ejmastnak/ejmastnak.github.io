#!/bin/sh
lines=3
recording_file="record.tex"
font_size="large"
geometry=`sh "../../resources/geometry.sh" ${lines}`

# Temporarily increase font size
sh "../../resources/font-big.sh"

# Start screenkey
sh "../../resources/start-screenkey.sh" "${geometry}" "${font_size}" &

# Set initial file contents
echo '$ 1 + 1 = 2 $' > ${recording_file}
    
# Open Vim to edit the demonstration file 
nvim -c "Goyo" \
     -c "set number" \
     -c "set nocursorline" \
     -c 'nmap cs$ <plug>(vimtex-env-change-math)' \
  ${recording_file}

# Close screenkey after Vim closes
kill $(pgrep screenkey)

# Reset font to normal size
sh "../../resources/font-small.sh"
