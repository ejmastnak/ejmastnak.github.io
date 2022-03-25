#!/bin/sh
lines=7
recording_file="record.tex"
font_size="medium"
geometry=`sh "../../resources/geometry.sh" ${lines}`

# Temporarily increase font size
sh "../../resources/font-big.sh"
sleep 0.5

# Start screenkey
sh "../../resources/start-screenkey.sh" "${geometry}" "${font_size}" &

# Set initial file contents
echo '\begin{frame}' > ${recording_file}
echo '    Frame 1' >> ${recording_file}
echo '\end{frame}' >> ${recording_file}
echo '' >> ${recording_file}
echo "% I'm not a frame and will be skipped!" >> ${recording_file}
echo '' >> ${recording_file}
echo '\begin{frame}' >> ${recording_file}
echo '    Frame 2' >> ${recording_file}
echo '\end{frame}' >> ${recording_file}

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
