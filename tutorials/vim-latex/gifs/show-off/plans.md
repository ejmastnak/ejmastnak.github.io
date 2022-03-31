## Format
Mozilla docs would recommend the VP9 codec and a WebM container; alternatively AVC (H.264) codec and MP4 container.

## Execution
- Run `_record-ffmpeg.sh`; countdown e.g. 3 seconds
- Run `_start-vim.sh`
- Begin typing when screen clears; start time of typing doesn't need to be exact, since output video will be trimmed anyway
- Wait with final output on display for a little while before stopping recording.

## Configuration

### Geometry
- Recorded on a 1920x1080 monitor using i3 window manager
- Terminal font: Source Code Pro; 38 pt font
- LaTeX document compiled with
  ```tex
  \documentclass[12pt, a4paper]{article}
  \fontsize{25}{25}\selectfont
  ```
- Used `mupdf` with 376 DPI
  ```
  mupdf -r 376 file.pdf
  ```
  
### Vim
Create a local `config.vim` file with:
```vim
set nonumber
set nocursorline
set nowrap
set linebreak
set textwidth=53

unlet g:UltiSnipsJumpForwardTrigger
let g:UltiSnipsJumpForwardTrigger = "<Tab>"
function! JumpAndWrite() abort
  call UltiSnips#JumpForwards()
  write
endfunction
inoremap jk <Cmd>call JumpAndWrite()<CR>

noremap <leader>r <Cmd>update<CR><Cmd>VimtexCompile<CR>
augroup vimtex_event_focus
  au!
  au User VimtexEventView execute ":!i3-msg focus down"
augroup END
augroup vimtex_event_close
  au!
augroup END
```

### LaTeX preamble
```tex
\documentclass[12pt, a4paper]{article}
\usepackage{amsmath, amssymb, mathtools, bm, esint}
\usepackage{xcolor}
\definecolor{nord0}{HTML}{2e3440}
\color{nord0}  % set desired text color
```
To hide equations, you can use `\[ \]` with lots of blank lines.
To make `pdflatex` ignore blank lines in math mode, add the following to your preamble:
```tex
\everymath=\expandafter{\the\everymath\let\par\relax}
\everydisplay=\expandafter{\the\everydisplay\let\par\relax}
```

### Starting Vim
Call `VimtexView`, which will open `mupdf`.
Call `VimtexCompile`, which will compile document after each save.
VimTeX takes care of sending SIGHUP to mupdf after successful compilation.

