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
echo '\begin{equation*}' > ${recording_file}
echo '    x + y = z' >> ${recording_file}
echo '\end{equation*}' >> ${recording_file}
echo '% Text and comments are skipped!' >> ${recording_file}
echo '' >> ${recording_file}
echo '\begin{itemize}' >> ${recording_file}
echo '    \item Item 1' >> ${recording_file}
echo '    \item Item 2' >> ${recording_file}
echo '\end{itemize}' >> ${recording_file}


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
