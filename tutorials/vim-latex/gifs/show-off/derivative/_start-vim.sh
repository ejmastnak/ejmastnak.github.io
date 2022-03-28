#!/bin/sh
term_font_size="large"
screenkey_font_size="medium"
content_file="derivative.tex"
recording_file="record.tex"
recording_pdf="record.pdf"

geometry=`tail -1 "../_geometry.txt"`

# mupdf background colors and dpi
light="fbfbfc"
nord4="d8dee9"
nord5="e5e9f0"
nord6="eceff4"
dpi=376

# Temporarily increase font size
sh "../../resources/change-font.sh" $(head -1 "../../resources/font-${term_font_size}.txt" )
sleep 0.5  # give Alacritty time to auto-update font

# Open pdf
i3-msg split v  # so mupdf opens below (and not the the right of) Vim
mupdf -C ${light} -r ${dpi} "${recording_pdf}" &
mupdf_pid=${!}

# give mupdf time to open, then move it to top of screen
sleep 1  
i3-msg move up

# Center text in mupdf
mupdf_window_id=`xdotool search --name "${recording_pdf}"`
xdotool key --window ${mupdf_window_id} W
xdotool key --window ${mupdf_window_id} j
xdotool click --window ${mupdf_window_id} 4
xdotool click --window ${mupdf_window_id} 4

# Set initial file contents
cp -f "${content_file}" ${recording_file}

# Start screenkey
sh "../../resources/start-screenkey.sh" "${geometry}" "${screenkey_font_size}" "--persist" &

# Open Vim to edit the demonstration file 
nvim -c "source ../_config.vim" \
     -c "9" \
     -c "VimtexCompile" \
     -c "silent! VimtexView" \
     -c "normal zt" \
     -c "startinsert!" \
  ${recording_file}

# Use -f to ignore potentially non-existent files
rm -f *.aux
rm -f *.fdb_latexmk
rm -f *.fls
rm -f *.log
rm -f *.out
rm -f *.synctex*

# Close screenkey and mupdf after Vim closes
kill $(pgrep screenkey)
kill ${mupdf_pid}

# Reset font to normal size
sh "../../resources/change-font.sh" $(head -1 "../../resources/font-normal.txt" )
