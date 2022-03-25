#!/bin/sh
recording_file="record.tex"
lines=7
font_size="medium"
geometry=`sh "../../resources/geometry.sh" ${lines}`

# Temporarily increase font size
sh "../../resources/font-big.sh"

# Start screenkey
sh "../../resources/start-screenkey.sh" "${geometry}" "${font_size}" &

# Set initial file contents
echo '% Delimeter' > ${recording_file}
echo '\left( \int_{a}^{b} f(x) \diff x \right)' >> ${recording_file}
echo '' >> ${recording_file}
echo '% Environment' >> ${recording_file}
echo '\begin{equation*}' >> ${recording_file}
echo '    x + y = z' >> ${recording_file}
echo '\end{equation*}' >> ${recording_file}

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
