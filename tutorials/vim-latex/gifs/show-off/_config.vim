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
