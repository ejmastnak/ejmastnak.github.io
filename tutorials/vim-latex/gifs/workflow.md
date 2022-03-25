## Layout and style
- Neovim running Goyo and potentially Limelight
- Screenkeys showing typed keys
- Alacritty, tmux, Neovim, and screenkey using Nord colors
- Alacritty and screenkey using Source Code Pro font

## Planning
For each GIF...
- Create a dedicated directory to hold the GIF
- Plan out beforehand what you are going to type
- Type it out get the final screen occupation size 
  (or perhaps just use a few standard values for uniformity)
- Record screen occupation with `slop` from within Vim
  ```vim
  r!slop -o
  ```
- Create a dedicated `_record.sh` script in the GIF's directory to handle starting `menyoki`
- Create a dedicated `_start-vim.sh` script to handle launching Vim with correct initial file content
