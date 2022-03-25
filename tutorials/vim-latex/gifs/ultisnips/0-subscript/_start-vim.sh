#!/bin/sh
recording_file="record.tex"
lines=5
font_size="medium"
geometry=`sh "../../resources/geometry.sh" ${lines}`

# Temporarily increase font size
sh "../../resources/font-big.sh"

# Start screenkey
sh "../../resources/start-screenkey.sh" "${geometry}" "${font_size}" &

# Set initial file contents
echo '% Expands' > ${recording_file}
echo '' >> ${recording_file}
echo "% Won't expand" >> ${recording_file}
echo '' >> ${recording_file}

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
