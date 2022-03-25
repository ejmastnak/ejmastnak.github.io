normal_font_size=10
big_font_size=38
alacritty_config="${HOME}/.config/alacritty/alacritty.yml"

# Temporarily increase font size (until Vim closes)
# to improve quality of recorded GIF.
sed -i "s/^  size: ${normal_font_size}/  size: ${big_font_size}/" ${alacritty_config}
