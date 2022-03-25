#!/bin/sh
lines=4
recording_file="record.tex"
font_size="large"
geometry=`sh "../../resources/geometry.sh" ${lines}`

# Temporarily increase font size
sh "../../resources/font-big.sh"
sleep 0.5

# Start screenkey
sh "../../resources/start-screenkey.sh" "${geometry}" "${font_size}" &

# Set initial file contents
echo '\frac{a}{b}' > ${recording_file}
echo '' >> ${recording_file}
echo '% Correctly handles multi-character fields!' >> ${recording_file}
echo '\frac{x + y}{2}' >> ${recording_file}

# Open Vim to edit the demonstration file 
nvim -c "Goyo" \
     -c "Limelight" \
     -c "set number" \
     -c "set nocursorline" \
  ${recording_file}

# Close screenkey after Vim closes
kill $(pgrep screenkey)

# Reset font to normal size
sh "../../resources/font-small.sh"
