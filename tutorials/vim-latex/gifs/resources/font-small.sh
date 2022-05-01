normal_font_size=11
alacritty_config="${HOME}/.config/alacritty/alacritty.yml"

# Reset font to normal size
sed -i "s/^  size: [0-9]\+\./  size: ${normal_font_size}./" ${alacritty_config}
