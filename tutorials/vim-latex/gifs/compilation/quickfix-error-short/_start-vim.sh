#!/bin/sh
vim_font_size="medium"
screenkey_font_size="medium"
recording_file="record.tex"
geometry=`tail -1 "geometry.txt"`

# Temporarily increase font size
sh "../../resources/change-font.sh" $(head -1 "../../resources/font-${vim_font_size}.txt" )
sleep 0.5  # give Alacritty time to auto-update font

# Start screenkey
sh "../../resources/start-screenkey.sh" "${geometry}" "${screenkey_font_size}" &

# Set initial file contents
echo '\input{preamble.tex}' > ${recording_file}
echo '\begin{document}' >> ${recording_file}
echo '' >> ${recording_file}
echo '\section{Section 1}' >> ${recording_file}
echo '\lipsum[1-3]' >> ${recording_file}
echo '' >> ${recording_file}
echo '% Error: missing $ $ math delimiters!' >> ${recording_file}
echo '\int_{a}^{b} f(x) \diff x' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '' >> ${recording_file}
echo '\end{document}' >> ${recording_file}

# Open Vim to edit the demonstration file 
nvim -c "4" \
     -c "copen 3" \
     -c "wincmd k" \
     -c "Limelight" \
     -c "set nocursorline" \
     -c "normal zt" \
  ${recording_file}

# Use -f to ignore potentially non-existent files
rm -f *.aux
rm -f *.fdb_latexmk
rm -f *.fls
rm -f *.log
rm -f *.out
rm -f *.synctex.gz
rm -f *.pdf

# Close screenkey after Vim closes
kill $(pgrep screenkey)

# Reset font to normal size
sh "../../resources/change-font.sh" $(head -1 "../../resources/font-normal.txt" )
