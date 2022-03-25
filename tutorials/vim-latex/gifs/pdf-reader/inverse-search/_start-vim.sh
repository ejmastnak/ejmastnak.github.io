#!/bin/sh
vim_font_size="medium"
screenkey_font_size="medium"
recording_file="record.tex"
geometry=`tail -1 "_geometry.txt"`

exec alacritty &
sleep 0.5

i3-msg "resize"
i3-msg resize shrink width 40 px or 40 ppt
i3-msg "resize"

i3-msg focus left

# Temporarily increase font size
sh "../../resources/change-font.sh" $(head -1 "../../resources/font-${vim_font_size}.txt" )
sleep 0.5  # give Alacritty time to auto-update font

# Start screenkey
sh "../../resources/start-screenkey.sh" "${geometry}" "${screenkey_font_size}" "-M" &

# Set initial file contents
cp -f "inverse-search.tex" ${recording_file}

# Open Vim to edit the demonstration file 
nvim -c "4" \
     -c "normal zt" \
     -c "5" \
     -c "Limelight 0.7" \
     -c "set nonumber" \
     -c "set cursorline" \
  ${recording_file}

# Use -f to ignore potentially non-existent files
rm -f *.aux
rm -f *.fdb_latexmk
rm -f *.fls
rm -f *.log
rm -f *.out

# Close screenkey after Vim closes
kill $(pgrep screenkey)

# Reset font to normal size
sh "../../resources/change-font.sh" $(head -1 "../../resources/font-normal.txt" )

i3-msg focus right
i3-msg kill
