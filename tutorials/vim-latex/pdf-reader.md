---
title: PDF Reader | Vim and LaTeX Part 1
---

# Setting Up a PDF Reader for Writing LaTeX with Vim

## Contents
<!-- vim-markdown-toc Marked -->

* [Desired functionality](#desired-functionality)
* [Implementation with Skim](#implementation-with-skim)
    * [Forward search](#forward-search)
    * [Backward search](#backward-search)
      * [Tex](#tex)
      * [PDF](#pdf)

<!-- vim-markdown-toc -->

## Desired functionality
An external PDF reader for displaying the `pdf` file associated with the `tex` source file being edited in Neovim.

1. The PDF reader should listen for changes to the `pdf` document and automatically update when the document’s contents change after compilation.

1. Forward search: jump to the PDF position corresponding the current cursor position in the `tex` document. Triggered with a convenient keyboard shortcut from Vim.

1. Backward search: move cursor to the line in the `tex` document corresponding to a line in the `pdf` document. Triggered by a simple click or keyboard shortcut in the PDF reader.

## Implementation with Skim
This tutorial covers the [Skim PDF reader](https://skim-app.sourceforge.io/) for macOS. Skim satisfies the first condition above by default; forward and backward search require some configuration.

#### Forward search
Skim ships with a script providing forward search. The script is called `displayline` and, assuming a default installation of Skim into `/Applications/`, lives at `/Applications/Skim.app/Contents/SharedSupport/displayline`.

The `displayline` call signature is
```
displayline [-r] [-b] [-g] LINE PDFFILE [TEXSOURCEFILE]
```
You are basically telling Skim, "jump to the position in `PDFFILE` corresponding to the line number `LINE` in the LaTeX source file `TEXSOURCEFILE`". You can read more about `displayline` at [on SourceForge](https://sourceforge.net/p/skim-app/wiki/TeX_and_PDF_Synchronization/#setting-up-your-editor-for-forward-search). For our purposes:
- `LINE` is the integer line number (starting at 1) in the `tex` source file from where the forward search is executed. 
- `PDFFILE` is the path to the to-be-displayed `pdf` file (and may be given relative to the directory from which `displayline` was called). In practice generally `./myfile.pdf`
- `TEXSOURCEFILE` is the path of the `tex` source file from which you make the `displayline` call. Generally `./myfile.tex`
- the `-b` option highlights jumped-to line in the PDF file in yellow. Basically you'd use `-b` to make it easier to see where Skim moved to. (You can change the color in `Skim>Preferences>Display>Reading bar`).
- the `-g` option disables switching window focus to Skim after `displayline` is called. You would use `-g` to keep focus in the text editor.
- the `-r` options "Revert the file from disk if it was open", idk I don't use it.

I implement forward search with the following Vimscript code, which I place in the file `nvim/ftplugin/tex/tex_compile.vim`.
```
# This code lives in the file nvim/ftplugin/tex/tex_compile.vim

# path to displayline script
let s:displayline = "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g"

# function implementing forward show
function! tex_compile#forward_show() abort
  execute "AsyncRun -silent -strip " . expand(s:displayline) . " " . line('.') . " $(VIM_RELDIR)/$(VIM_FILENOEXT).pdf $(VIM_RELDIR)/$(VIM_FILENAME)"
endfunction

# map forward show to <leader>v ("v" for "view")
noremap <Plug>TexForwardShow :call tex_compile#forward_show()<cr>
nmap <leader>v <Plug>TexForwardShow
```
You should now be able to access forward show with `<leader>v` in normal mode.

#### Backward search
Backward search is like asking, "hey PDF viewer, please take me to the position in the `tex` source file that corresponds to my current position in the `pdf` file". Positions in the `pdf` file are linked to the correct corresponding positions in the `tex` source file using a utility called SyncTeX, which is implemented in a binary program called `synctex`; `synctex` should ship by default with a standard TeX installation.

You trigger backward search in Skim using `Command`+`Shift`+`Mouse-Click` on a line in the `pdf` file.

##### Tex
On the `tex` side, you must compile your `tex` documents *with* `synctex` *enabled* to create the `pdf`-`tex` synchronization needed for backward search to work properly. You enable `synctex` by passing the `-synctex=1` option to `pdflatex` or `latexmk` when compiling your `tex` files. See `man synctex`, or search `man pdflatex` or `man latexmk` for `'synctex'` for more documentation. 

##### PDF
On the `pdf` side, in Skim, you enable SyncTex in `Skim > Preferences > Sync > PDF-TeX Sync Support`. If you use any of the text editors listed in `Preset`, just select your editor and backward search should work out of the box. (I can confirm the MacVim preset works out of the box.) 

Command line editors like Neovim Vim require manual configuration of the `Command` and `Argument` fields. Here are the values I use:
- `Command`: `nvr`
- `Argument`: `--servername=/tmp/texsocket +%line "%file" && open -a iTerm`

This almost certain won't work out of the box for you. Read on to understand why, and what actually happens. When you trigger backward search in Skim, Skim runs the shell command in the `Command` field with the arguments in the `Arguments` field; in my case this is the equivalent of opening a terminal and typing
```
nvr --servername=/tmp/texsocket +%line "%file" && open -a iTerm
```
When properly configured with SyncTeX, Skim gives you the following information to work with:
- the full path of the `tex` source file (stored in the `%file` macro)
- the line number in the `tex` source file corresponding to the position you clicked in the `pdf` file (stored in the `%line` macro)

Your job is to use `%line` and `%file` to construct a shell command that opens `%file` at line number `%line` in the editor of your preference. You need the `neovim-remote` package to be able to open Neovim remotely (in this case from Skim via the command line). You install `neovim-remote` with `pip3 install neovim-remote`; the corresponding executable is abbreviated to `nvr`. This is why the `Command` field reads `nvr`; using `nvim` won't work because `nvim` cannot open files remotely.

Neovim starts a server when launching; the server allows external processes to communicate with Neovim using an RPC protocol. The name of the current Neovim server (well, the name of the socket used to communicate with Neovim) is stored in the variable `v:servername`; see it with `echo v:servername`. To communicate remotely with Neovim, Skim must know Neovim's `servername`. By default, `servername` is randomly generated each time you open Neovim. You need to modify this behavior to create a consistent server name (at least for `tex` files you want to communicate remotely with). It's easy, just start Neovim with the `--listen-address` option set to the socket name of your choice. See `man nvim` and search for `--listen-address`. For example:
```
nvim myfile.tex  # doesn't set custom server name
nvim --listen-address=/tmp/nvimtexsocket myfile.tex
```
The server is documented under `:help client-server` or equivalently `:help remote.txt`, but note that this is documentation is for Vim, and might not transfer exactly to Neovim.

Yeah so the server thing needs explanation; `%file` is in quotation marks to handle possible spaces in file names. By default, in my experience, Skim does not switch focus back to your terminal editor. I add `&& open -a iTerm` to switch focus back to the application `iTerm` if the `nvr` command executes successfully.

