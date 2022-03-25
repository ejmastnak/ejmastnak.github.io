#!/bin/sh
lines=6
recording_file="record.tex"
font_size="medium"
geometry=`sh "../../resources/geometry.sh" ${lines}`

# Temporarily increase font size
sh "../../resources/font-big.sh"
sleep 0.5

# Start screenkey
sh "../../resources/start-screenkey.sh" "${geometry}" "${font_size}" &

# Set initial file contents
echo '\left( x + y \right)' > ${recording_file}
echo '' >> ${recording_file}
echo '$ x + y $' >> ${recording_file}
echo '' >> ${recording_file}
echo '\begin{quote}' >> ${recording_file}
echo '    A' >> ${recording_file}
echo '    long' >> ${recording_file}
echo '    multi-line' >> ${recording_file}
echo '    quote.' >> ${recording_file}
echo '\end{quote}' >> ${recording_file}

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
