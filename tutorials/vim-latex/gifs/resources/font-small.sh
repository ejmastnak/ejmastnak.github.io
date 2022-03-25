normal_font_size=10
big_font_size=28
alacritty_config="${HOME}/.config/alacritty/alacritty.yml"

# Reset font to normal size
sed -i "s/^  size: ${big_font_size}/  size: ${normal_font_size}/" ${alacritty_config}
