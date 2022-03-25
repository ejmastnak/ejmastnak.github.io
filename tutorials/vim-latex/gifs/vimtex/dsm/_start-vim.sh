#!/bin/sh
recording_file="record.tex"
lines=6
font_size="medium"
geometry=`sh "../../resources/geometry.sh" ${lines}`

# Temporarily increase font size
sh "../../resources/font-big.sh"

# Start screenkey
sh "../../resources/start-screenkey.sh" "${geometry}" "${font_size}" &

# Set initial file contents
echo '$ 1 + 1 = 2 $' > ${recording_file}
echo '' >> ${recording_file}
echo '% Works with all math environments!' >> ${recording_file}
echo '\begin{equation*}' >> ${recording_file}
echo "Some text that shouldn't be in an equation!" >> ${recording_file}
echo '\end{equation*}' >> ${recording_file}
    
# Open Vim to edit the demonstration file 
nvim -c "Goyo" \
     -c "Limelight" \
     -c "set number" \
     -c "set nocursorline" \
     -c 'nmap ds$ <plug>(vimtex-env-delete-math)' \
  ${recording_file}

# Close screenkey after Vim closes
kill $(pgrep screenkey)

# Reset font to normal size
sh "../../resources/font-small.sh"
