#!/bin/sh
# Argument $1 New font size in points e.g. 10, 16, etc...
# Used to temporarily increase terminal font size to create 
# higher-resolution GIFs, and to subsequently return font
# size to normal after the screen recording finishes.

alacritty_config="${HOME}/.config/alacritty/alacritty.yml"
sed -i "s/^  size: [0-9]\+\./  size: ${1}./" ${alacritty_config}
