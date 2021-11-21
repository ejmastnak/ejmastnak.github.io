---
title: PDF Reader | Vim and LaTeX Part 3
---

# Setting Up a PDF Reader for Writing LaTeX with Vim

This is part three in a [four part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents. This article explains, for both macOS and Linux, how to set up an external PDF reader for displaying the `pdf` file associated with the `tex` source file being edited in Vim and also covers how to configure forward and inverse search.

## Contents of this article
<!-- vim-markdown-toc Marked -->

* [Functionality implemented in this article](#functionality-implemented-in-this-article)
* [Choosing a PDF Reader](#choosing-a-pdf-reader)
  * [On macOS](#on-macos)
  * [On Linux](#on-linux)
  * [On Windows](#on-windows)
* [Setting up Skim (read this on macOS)](#setting-up-skim-(read-this-on-macos))
  * [Forward search](#forward-search)
  * [Backward search](#backward-search)
    * [Compiling with SyncTex](#compiling-with-synctex)
    * [Configuring Neovim for remote process communication](#configuring-neovim-for-remote-process-communication)
    * [What to do in the PDF reader](#what-to-do-in-the-pdf-reader)
* [Setting Up Zathura (read this on Linux)](#setting-up-zathura-(read-this-on-linux))

<!-- vim-markdown-toc -->

## Functionality implemented in this article
This article covers the following features:

1. My suggestion for a PDF reader (Skim on macOS and Zathura on Linux) and why

1. Implementing forward search: jump to the PDF position corresponding the current cursor position in the `tex` document, triggered with a convenient keyboard shortcut from Vim.

1. Implementing inverse search: move cursor to the line in the `tex` document corresponding to a line in the `pdf` document, triggered by a simple click or keyboard shortcut in the PDF reader.

## Choosing a PDF Reader
The big picture here is to configure an external PDF reader to display the `pdf` file associated with the `tex` source file being edited in Vim. Your LaTeX experience will improve dramatically if...

- The PDF reader, in the background, constantly listens for changes to the `pdf` document and automatically updates its display when the document’s contents change after compilation.

  The alternative: manually switch applications to the PDF reader, refresh the document, and switch back to Vim for *every single compilation*. You would tire of this pretty quickly. (Or I guess you could hack together a shell script, but why bother?)
- The PDF reader supports forward search. More on this in **TODO** 
- The PDF reader supports SyncTeX integration, which makes inverse search possible. More on this in **TODO** 

### On macOS
On macOS, to the best of my knowledge, you have basically one option meeting the above three criteria: [Skim](https://skim-app.sourceforge.io/). You can download Skim from the [homepage](https://skim-app.sourceforge.io/) or from [SourceForge](https://sourceforge.net/projects/skim-app/). macOS's default PDF reader, Preview, does not listen for document changes, nor, to the best of my knowledge, does it support SyncTeX integration.

### On Linux
On Linux you are blessed with a variety of options. I will cover Zathura, under the assumption that anyone reading a multi-article Vim series will also appreciate Zathura's Vim-like key bindings and text-based configurability. Many more possibilities are covered in the `vimtex` plugin's documentation at `help g:vimtex_view_method`

### On Windows
I have not tested it myself and will not cover it in this article, but supposedly the SumatraPDF viewer supports both forward and backward search. This is covered, for example, in the `vimtex` plugin's documentation at `help vimtex_viewer_sumatrapdf`. See also `help g:vimtex_view_method` for other possibilities on Windows.

## Setting up Skim (read this on macOS)

### Forward search
Skim ships with a script providing forward search; this script is called `displayline` and, assuming a default installation of Skim into macOS's `/Applications` folder, lives at `/Applications/Skim.app/Contents/SharedSupport/displayline`.

The `displayline` call signature is
```
displayline [-r] [-b] [-g] LINE PDFFILE [TEXSOURCEFILE]
```
You are basically telling Skim, "jump to the position in `PDFFILE` corresponding to the line number `LINE` in the LaTeX source file `TEXSOURCEFILE`". You can read more about `displayline` at [on SourceForge](https://sourceforge.net/p/skim-app/wiki/TeX_and_PDF_Synchronization/#setting-up-your-editor-for-forward-search). For our purposes:
- `LINE` is the integer line number (starting at 1) in the `tex` source file from where the forward search is executed. 
- `PDFFILE` is the path to the to-be-displayed `pdf` file (and may be given relative to the directory from which `displayline` was called).
- `TEXSOURCEFILE` is the path of the `tex` source file from which you make the `displayline` call.
- the `-b` option highlights the jumped-to line in the PDF file in yellow. Use the `-b` option, if desired, to make it easier to see what line Skim moved to. (You can change the color in `Skim>Preferences>Display>Reading bar`).
- the `-g` option disables switching window focus to Skim after `displayline` is called; use `-g` to keep focus in your text editor.
- I don't know what the `-r` option does. The `displayline` documentation has the following to say: `-r, -revert Revert the file from disk if it was open`. Let me known if you know what it does!

As an example, I map forward search to `<leader>v` (using `v` reminds me of "view"), which I implement with the following Vimscript code:
- If using `asyncrun.vim`, place the following in `ftplugin/tex.vim`:
  ```vim
  nnoremap <leader>v :execute "AsyncRun -silent -strip " . 
        \ "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g " .
        \ line('.') .
        \ " $(VIM_RELDIR)/$(VIM_FILENOEXT).pdf" .
        \ " $(VIM_RELNAME)"<CR>
  ```
  Since I don't want any output from forward search commands, I use the `AsyncRun` options `-silent` and `-strip` to stop the QuickFix menu from opening and to suppress AsyncRun's status messages. These are documented in `:help asyncrun-run-shell-command`, but you have to scroll down a bit.

- If using `vim-dispatch`, place the following in `ftplugin/tex.vim`:
  ```vim
  nnoremap <leader>v :execute "Start! sh " .
        \ "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g " .
        \ line('.') . " " .
        \ expand('%:r') . ".pdf " .
        \ expand('%')<CR>

  " Goal: suppress all vim-dispatch output for the forward show command.
  " (Hacky) solution: Disable vim-dispatch's terminal mode for Start commands,
  " which makes vim-dispatch fall back to headless mode, which has no output.
  " (See `:help dispatch-strategies`.)
  let g:dispatch_no_terminal_start = 1
  let g:dispatch_no_iterm_start = 1
  let g:dispatch_no_x11_start = 1
  ```
  The macro `%` gives the current file name relative to Vim's CWD, and the modified version `%:r` gives the file name without extension. See `:help cmdline-special` and `:help filename-modifiers`.


In either case, you should now be able to access forward show with `<leader>v` in normal mode.


### Backward search
Backward search is like asking, "hey, PDF viewer, please take me to the position in the `tex` source file that corresponds to my current position in the `pdf` file". Positions in the `pdf` file are linked to the correct corresponding positions in the `tex` source file using a utility called SyncTeX, which is implemented in a binary program called `synctex`; `synctex` should ship by default with a standard TeX installation. 

You trigger backward search in Skim using `Command`+`Shift`+`Mouse-Click` on a line in the `pdf` file.

#### Compiling with SyncTex
Backwards search requires that your `tex` documents are compiled *with `synctex` enabled*. This is as simple as passing the `-synctex=1` option to `pdflatex` or `latexmk` when compiling your `tex` files, which was covered in the previous article, [Compiling LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %}). For more `synctex` documentation, see `man synctex` or search `man pdflatex` or `man latexmk` for `'synctex'`.

#### Configuring Neovim for remote process communication

#### What to do in the PDF reader
In Skim, you enable SyncTex in `Skim > Preferences > Sync > PDF-TeX Sync Support`. If you use any of the text editors listed in the `Preset` field, just select your editor and backward search should work out of the box. (I can confirm, for example, that the MacVim preset works out of the box.) 

Command line editors like Neovim and Vim require manual configuration of the `Command` and `Argument` fields. Here are the values I use:
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

## Setting Up Zathura (read this on Linux)
