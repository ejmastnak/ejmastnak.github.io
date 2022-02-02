---
title: PDF Reader \| Setting up Vim for LaTeX Part 4
---

# Setting Up a PDF Reader for Writing LaTeX with Vim

This is part five in a [six part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents.
This article explains, for both macOS and Linux, how to set up an external PDF reader for displaying the PDF file associated with the `tex` source file being edited in Vim.
The article also covers how to configure forward and backward search.

## Contents of this article
<!-- vim-markdown-toc GFM -->

* [Functionality implemented in this article](#functionality-implemented-in-this-article)
* [Choosing a PDF Reader](#choosing-a-pdf-reader)
  * [On macOS](#on-macos)
  * [On Linux](#on-linux)
  * [On Windows](#on-windows)
* [The big picture](#the-big-picture)
  * [What is forward search?](#what-is-forward-search)
  * [What is inverse search?](#what-is-inverse-search)
    * [Compiling with SyncTex](#compiling-with-synctex)
    * [The big idea: using Vim with remote procedure calls](#the-big-idea-using-vim-with-remote-procedure-calls)
  * [Desired functionality](#desired-functionality)
    * [Forward search](#forward-search)
    * [Inverse search](#inverse-search)
* [OS-agnostic steps](#os-agnostic-steps)
  * [Setting up Neovim for remote communication](#setting-up-neovim-for-remote-communication)
  * [Asynchronous command execution](#asynchronous-command-execution)
    * [Running shell scripts from Vim](#running-shell-scripts-from-vim)
      * [Naive implementation](#naive-implementation)
      * [Asynchronous commands with vim-dispatch](#asynchronous-commands-with-vim-dispatch)
* [Setting up Skim (read this on macOS)](#setting-up-skim-read-this-on-macos)
  * [Forward search with Skim](#forward-search-with-skim)
    * [Implementing forward show](#implementing-forward-show)
  * [Backward search](#backward-search)
    * [Backward search with MacVim and Skim](#backward-search-with-macvim-and-skim)
    * [Backward search with Neovim and Skim](#backward-search-with-neovim-and-skim)
    * [Backward search with Vim and Skim](#backward-search-with-vim-and-skim)
* [Setting Up Zathura (read this on Linux)](#setting-up-zathura-read-this-on-linux)
  * [Implementation](#implementation)
  * [Documentation](#documentation)
    * [Window manager control](#window-manager-control)
    * [Forward search](#forward-search-1)
      * [`synctex view` documentation](#synctex-view-documentation)
      * [Zathura forward search documentation](#zathura-forward-search-documentation)
    * [Backward search](#backward-search-1)
      * [`synctex edit` documentation](#synctex-edit-documentation)
      * [Zathura's inverse search documentation](#zathuras-inverse-search-documentation)

<!-- vim-markdown-toc -->

## Functionality implemented in this article
This article covers the following:

1. My suggestion for a PDF reader (Skim on macOS and Zathura on Linux) and the reasons for these choices.

1. Implementing forward search, i.e. jumping to the position in the PDF document corresponding the current cursor position in the `tex` document, triggered with a convenient keyboard shortcut from Vim.

1. Implementing inverse search, i.e. switching focus from a line in the PDF document to the corresponding line in the `tex` source file, triggered by a simple click or keyboard shortcut in the PDF reader.

## Choosing a PDF Reader
The big picture here is to configure an external PDF reader to display the PDF file associated with the `tex` source file being edited in Vim.
You want  PDF reader that:

- in the background, constantly listens for changes to the PDF document and automatically updates its display when the document’s contents change after compilation.
  (The alternative: manually switch applications to the PDF reader, refresh the document, and switch back to Vim for *every single compilation*.
  You would tire of this pretty quickly.
  Or I guess you could hack together a shell script to do this for you, but why bother?)
  
- Integrates with a program called SyncTeX, which makes both forward and inverse search possible.

For orientation, here's what forward and inverse search look like: **TODO** GIFs

### On macOS
On macOS, to the best of my knowledge, you have basically one option meeting the above criteria: [Skim](https://skim-app.sourceforge.io/).
You can download Skim from the [homepage](https://skim-app.sourceforge.io/) or from [SourceForge](https://sourceforge.net/projects/skim-app/).
The default macOS PDF reader, Preview, does not listen for document changes, nor, to the best of my knowledge, does it support SyncTeX.
<!-- (It is also possible to build Zathura on macOS!) -->

### On Linux
On Linux you have a variety of options.
In this article I will cover Zathura, under the assumption that anyone reading a multi-article Vim series will also appreciate Zathura's Vim-like key bindings and text-based configurability.
Many more possibilities are covered in the `vimtex` plugin's documentation at `help g:vimtex_view_method`.

### On Windows
I have not tested it myself and will not cover it in this article, but supposedly the SumatraPDF viewer supports both forward and backward search.
This is covered, for example, in the `vimtex` plugin's documentation at `help vimtex_viewer_sumatrapdf`.
See also `help g:vimtex_view_method` for other PDF reader possibilities on Windows.

<!-- TODO: link to jdhao's inverse search. -->

## The big picture
Many of the same ideas and configuration steps apply on both macOS and Linux.
To avoid repetition, I will list all steps applicable to both platforms here.
OS-specific implementation specifics appear below.

### What is forward search?
What is involved: a text editor used to edit a plain-text LaTeX file and a PDF reader displaying the PDF associated with the LaTeX file.

Forward search is triggered from the text editor.
A command triggered in the text editor moves the PDF reader's focus to the line in the PDF file corresponding to the line in the LaTeX file at which forward search was triggered.

In everyday language: hey, PDF reader, show the position in the PDF file corresponding to my current position in the LaTeX file.

### What is inverse search?
Backward search is like asking, "hey, PDF viewer, please take me to the position in the `tex` source file corresponding to my current position in the PDF file".
Backward search looks something like this: **TODO** GIF.

Positions in the PDF file can be linked to positions in the `tex` source file using a utility called SyncTeX, which is implemented in a binary program called `synctex`; `synctex` should ship by default with a standard TeX installation.

**Note** Vim might not create a listen address at `/tmp/texsocket` if a file `/tmp/texsocket` already exists there from a different LaTeX document.
In this case `v:servername` will default to something random and it will seem like backward search won't work.
Deleting the existing `/tmp/texsocket` should solve the problem.

#### Compiling with SyncTex
Backwards search requires that your `tex` documents are compiled *with `synctex` enabled*.
This is as simple as passing the `-synctex=1` option to the `pdflatex` or `latexmk` programs when compiling your `tex` files, which is covered in the previous article, [Compiling LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %}).
**TODO** link to section.

For more `synctex` documentation, see `man synctex` or search `man pdflatex` or `man latexmk` for `'synctex'`.

#### The big idea: using Vim with remote procedure calls
Here is the big picture: we need one program---the PDF reader---to be able to access and open a second program---Vim---and ideally open Vim at a specific line.
This type of inter-program interaction is possible because of Vim's built-in [remote procedure call protocol](https://en.wikipedia.org/wiki/Remote_procedure_call).
The RPC implementation is different in Vim and Neovim---see `:help remote.txt` for Vim and `:help RPC` for Neovim.

In practice, setting up Vim or Neovim for backward search is fairly straightforward, once you know what to do.
And although the hard work is taken care of for us in the Vim/Neovim source code, it is still instructive to keep in mind that an RPC protocol and client-server model are required under the hood for backward search to work.

Since the steps in Vim and Neovim are slightly different, I explain them in two different sections below.

### Desired functionality
#### Forward search
Trigger forward search by pressing a key combination of your choice (e.g. `<leader>f`) while editing a LaTeX document in Vim.

- If PDF reader is not open
  1. Launch a new PDF reader instance displaying the PDF file associated with the LaTeX document from which forward search was triggered.
     
  1. Move PDF reader display to line in the PDF corresponding to cursor position in Vim at which `<leader>f` was pressed.
  1. Optionally highlight displayed line in PDF reader using a color of your choice.
  1. If desired, immediately return focus to Vim if it was stolen by the PDF reader opening.

- If PDF reader is already open and displaying the PDF file associated with the LaTeX file from which forward search was triggered, perform steps (ii-iv) above.

#### Inverse search
Trigger inverse search by performing a PDF-reader-specific mouse/key combination on a line in the PDF reader.

- Remotely move the cursor in Vim to the position in the LaTeX source file corresponding to the line in the PDF where the inverse search clicked occured in the PDF reader.

- If desired, immediately move focus to Vim.

## OS-agnostic steps
### Setting up Neovim for remote communication
Perform this on either macOS or Linux.

1. Install the `neovim-remote` Python module, which is required for Neovim to work with RPC.
   You can do this with `pip` just like any other Python package:
   ```
   pip install neovim-remote
   ```
   The `neovim-remote` executable is abbreviated to `nvr`, just like the `neovim` executable is abbreviated to `nvim`.

1. To use `neovim-remote` (or any Python plugin) with Neovim, you need the `pynvim` module.
   Install it with
   ```
   pip install pynvim
   ```
   
1. When you open a `*.tex` file with Neovim, use the following command
   ```
   nvim --listen /tmp/texsocket myfile.tex
   ```
   Explanation: Neovim starts a server when launching, and this server allows external processes to communicate with Neovim using an RPC protocol.
   By default, the server's listen address, (i.e. the location where programs that wish to communicate with Neovim should send commands) is randomly generated each time you open Neovim---you can view the current value with `:echo v:servername`.
   Try `:echo v:servername` once after launching Neovim with the `--listen /tmp/texsocket` option and once without---you should see something wierd like `/var/folders/c2/lx18_n3d1vx2jklrvj06lmbh0000gn/T/nvimUTaK3R/0` in the former case and `/tmp/texsocket` in the latter. 
   <!-- You can also check your `/tmp` directory to see if `/tmp/texsocket` was created. -->

   To communicate remotely with Neovim, Skim must know Neovim's listen address, and all that the command `nvim --listen /tmp/texsocket myfile.tex` does is launch Neovim using the file `/tmp/texsocket` as a listen address (see `:help --listen`).
   Using "socket" in the name is conventional because the file is a [*Unix domain socket*](https://en.wikipedia.org/wiki/Unix_domain_socket), but you could name the listen address whatever you want, as long as you can remember and reference the name later in Skim.

   Of course, you don't want to go around typing `nvim --listen /tmp/texsocket` everytime you edit a LaTeX file.
   I have two suggestions:
   1. Configure your file manager (you have a highly-configurable command line file manager if you're using Neovim, right?) to open `*.tex` files using the command `nvim --listen /tmp/texsocket`. For example, I use the [`vifm` file manager](https://vifm.info/) and add the following to my `~/.config/vifm/vifmrc`:
      ```vim
      filetype {*.tex},<text/tex> nvim --listen /tmp/texsocket
      ```
      This opens all `*.tex` files with the command `nvim --listen /tmp/texsocket`; other command-line file browsers should have similar functionality.

   1. Create a convenient shell alias, e.g. in your `~/.bashrc` if you use Bash, that you use for LaTeX files.
      For example:
      ```sh
      alias tvim='nvim --listen /tmp/texsocket'
      ```
      You would then open `*.tex` files manually with `tvim myfile.tex` instead of `nvim myfile.tex`; of course change `tvim` to whatever you want.

### Asynchronous command execution
#### Running shell scripts from Vim
The idea here, just like with compilation in the [previous article]({% link tutorials/vim-latex/compilation.md %}), is to call Skim's `displayline` script, a *shell script* normally called from the command line, *from within Vim*.
Additionally, the `displayline` script should run asynchronously, to not freeze up Vim.

##### Naive implementation
The simplest way to execute shell commands from Vim is Vim's `:!{command}` functionality, which is documented at `:help :!cmd`.
The process is straightforward: 

1. in normal mode, enter `:` to enter Vim's command mode
1. type `!`
1. type a shell command and press Enter.

For example, running `:!pdflatex myfile.tex` from Vim's command-line mode has the same effect as running `pdflatex myfile.tex` in a terminal emulator.

##### Asynchronous commands with vim-dispatch
- Problem: Vim's built-in `:!{command}` functionality runs synchronously---this means Vim freezes until the shell command finishes executing.
For execution times over a few tens of milliseconds, this delay is unacceptable.
Try running `:!pdflatex %` on a LaTeX file and see for yourself (`%` is a Vim macro for the current file).

- Hacked solution: run the command in the background with `:!{command}&`.
  This works only on Unix systems and won't show any output.

- Actual solution: use an *asynchronous build plugin*.

Asynchronous build plugins allow you to run shell commands asynchronously from within Vim without freezing up your editor.
For this series I recommend Tim Pope's [`vim-dispatch`](https://github.com/tpope/vim-dispatch), but I have also used [skywind300](https://github.com/skywind3000)'s [asyncrun.vim](https://github.com/skywind3000/asyncrun.vim) with good results.
You can install Dispatch or AsyncRun with the installation method of your choice, just like any other Vim plugin (see **TODO** prequisites).

Both are straightforward to use---Dispatch provides a `:Start!` command while AsyncRun provides an `:AsyncRun` command; both are asynchronous equivalents of `:!`.
For example:
```vim
:! pdflatex displayline 42 myfile.pdf myfile.tex  " show line 42 synchronously
:Start! displayline 42 myfile.pdf myfile.tex      " show line 42 asynchronously
:AsyncRun displayline 42 myfile.pdf myfile.tex    " show line 42 asynchronously
```

## Setting up Skim (read this on macOS)
First enable automatic document refreshing (so Skim will automatically update the displayed PDF after each compilation): open Skim and navigate to `Preference` > `Sync` and select `Check for file changes` and `Reload automatically`.

### Forward search with Skim
Skim ships with a shell script providing forward search---this script is called `displayline` and, for a default installation of Skim in macOS's `/Applications` folder, is found at `/Applications/Skim.app/Contents/SharedSupport/displayline`.

The `displayline` call signature is
```
displayline [-r] [-b] [-g] LINE PDFFILE [TEXSOURCEFILE]
```
You are basically telling Skim, "jump to the position in `PDFFILE` corresponding to the line number `LINE` in the LaTeX source file `TEXSOURCEFILE`".
You can read more about `displayline` at [on SourceForge](https://sourceforge.net/p/skim-app/wiki/TeX_and_PDF_Synchronization/#setting-up-your-editor-for-forward-search).
For our purposes:
- `LINE` is the integer line number (starting at 1) in the `tex` source file from where the forward search is executed.
- `PDFFILE` is the path to the to-be-displayed PDF file (and may be given relative to the directory from which `displayline` was called).
- `TEXSOURCEFILE` is the path of the `tex` source file from which you make the `displayline` call.
- the `-b` option highlights the jumped-to line in the PDF file in yellow.
  Use the `-b` option, if desired, to make it easier to see what line Skim moved to.
  (You can change the color in `Skim>Preferences>Display>Reading bar`).
- the `-g` option disables switching window focus to Skim after `displayline` is called; use `-g` to keep focus in your text editor.
- I don't know what the `-r` option does.
  The `displayline` documentation has the following to say: `-r, -revert Revert the file from disk if it was open`.
  Please let me know if you know know more!

For example, if run from a shell, a `displayline` call to show the PDF position associated with line 42 of the LaTeX file `myfile.tex`, using the `b` and `g` options, would read
```sh
/Applications/Skim.app/Contents/SharedSupport/displayline -bg 42 myfile.pdf myfile.tex
```
I use the full path to the displayline script, but I suppose if you add the script to your `PATH` environment variable you could use just `displayline`.

#### Implementing forward show
Suppose you wanted to use the key combination `<leader>f`, in normal mode, to trigger asynchronous forward search from the current `tex` file.
Here's what you would do:

- **TODO** If using Neovim's built-in jobs feature...

- If using Vim 8+'s built-in jobs feature...

- If using `vim-dispatch`, place the following in `ftplugin/tex.vim`:
  ```vim
  nnoremap <leader>f :execute "Start! " .
        \ "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g " .
        \ line('.') . " " .
        \ expand('%:r') . ".pdf " .
        \ expand('%')<CR>
  ```
  The macro `%` gives the current file name relative to Vim's CWD, and the modified version `%:r` gives the file name without extension.
  See `:help cmdline-special` and `:help filename-modifiers`.
  **TODO** also link to compilation or maybe just cover Vim's `filename-modifiers` in the Vimscript theory article.

  There is one potential issue: by default `vim-dispatch` tries to open a new window to show the `Start!` command's output.
  This is great when viewing compilation logs, but I find it disorienting for forward search, where I just want to jump to the PDF reader with minimal distractions.
  You can force the `Start!` command into `headless` mode, which won't open a new window, with the following configuration:
  ```vim
  let g:dispatch_no_tmux_start = 1
  let g:dispatch_no_screen_start = 1
  let g:dispatch_no_terminal_start = 1
  let g:dispatch_no_windows_start = 1
  let g:dispatch_no_iterm_start = 1
  let g:dispatch_no_x11_start = 1
  ```
  You could add this code, for example, just below the forward search key mapping to `<leader>f`.
  I recommend reading `:help dispatch-strategies` to see `vim-dispatch`'s runtime handlers, their order of preference, and how to disable them as shown above.
  You can view the handlers with `echo g:dispatch_handlers` or, if you're interested, check the `vim-dispatch` source code in `vim-dispatch/plugin/dispatch.vim` (line 88 at the time of writing).

- If using `asyncrun.vim`, place the following in `ftplugin/tex.vim`:
  ```vim
  nnoremap <leader>f :execute "AsyncRun -silent -strip " .
        \ "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g " .
        \ line('.') .
        \ " $(VIM_RELDIR)/$(VIM_FILENOEXT).pdf" .
        \ " $(VIM_RELNAME)"<CR>
  ```
  Because I prefer to silence output from forward search commands, I included the `AsyncRun` options `-silent` and `-strip` to stop the QuickFix menu from opening and to suppress AsyncRun's status messages.
  These are documented in `:help asyncrun-run-shell-command`, but you have to scroll down a bit.

That's it! In either case, you should now be able to access forward show with `<leader>f` in normal mode.


### Backward search
You trigger backward search in Skim using `Command`+`Shift`+`Mouse-Click` on a line in the PDF file.
For orientation, scroll up to the section [What is inverse search?](#what-is-inverse-search) for a big-picture idea of what inverse search actually is.

First enable SyncTex integration in Skim by opening Skim and navigating to `Preferences > Sync > PDF-TeX Sync Support`.

#### Backward search with MacVim and Skim
In case you use the GUI editor MacVim, basically everything is done for you.
Open Skim and navigate to `Preferences > Sync`.
If you use any of the text editors listed in the `Preset` field, including MacVim, just select your editor and backward search should work out of the box, assuming you compile your LaTeX documents with SyncTex enabled.

#### Backward search with Neovim and Skim
Things on Neovim are a bit more involved, but not too bad.
First scroll back up and follow the steps for [Setting up Neovim for remote communication](#setting-up-neovim-for-remote-communication).
Then perform the following configuration in Skim:

1. Open Skim and enable SyncTex in `Skim > Preferences > Sync > PDF-TeX Sync Support`.

1. Command line editors like Neovim and Vim require custom configuration of the `Command` and `Argument` fields.
   If you prefer the TLDR version, here are the values I use:
   - `Command`: `nvr`
   - `Argument`: `--servername=/tmp/texsocket +%line "%file"`

   And here's an explanation: When you trigger backward search in Skim, Skim runs the shell command in the `Command` field using the arguments in the `Arguments` field; in my case, if you ignore the Skim-specific `%line` and `%file` macros for a moment, this is the equivalent of opening a terminal and typing
   ```
   nvr --servername=/tmp/texsocket +%line "%file"
   ```
   About the macros: when properly configured with SyncTeX, Skim gives you the following information to work with:
   - the full path of the `tex` source file to open in Neovim (stored in the `%file` macro), and
   - the line number in the `tex` source file corresponding to the position you clicked in the PDF file (stored in the `%line` macro)

   Your job is to use the `%line` and `%file` macros to construct a shell command that opens `%file` at line number `%line` in the editor of your preference.
   You need the `neovim-remote` script to open Neovim remotely; this is why the `Command` field reads `nvr` and not `nvim`; using `nvim` won't work because `nvim` cannot open files remotely.
   Note that the `%file` macro is quoted to escape potential white spaces in file names.

   Finally, the `+%line` thing (which might evaluate in practice to, say, `+42` or `+100`) just opens Neovim at the line contained in Skim's `%line` macro.
   In general, `nvim +[linenum]` or `nvr +[linenum]` opens Neovim with the cursor positioned at line `linenum`---this is documented in the `OPTIONS` section of `man nvim`, but you have to scroll down a bit.
   For more information about `neovim-remote`, enter `nvr --help` on a command line.

**Tip: Return focus to Neovim** 

By default, in my experience, Skim does not switch focus back to terminal editors (it does for MacVim, though).
To get around this, you can append `&& open -a iTerm` (if you use `iTerm` as your terminal, for example) to switch focus back to `iTerm` once the `nvr` command executes successfully.
The full Skim backward search fields would then read

- `Command`: `nvr`
- `Argument`: `--servername=/tmp/texsocket +%line "%file" && open -a iTerm`

Of course replace `iTerm` with the terminal application of your choice, e.g. `open -a Alacritty` or `open -a Terminal`.
(The `open -a` command is a macOS command that opens a given application.)

**Another approach:** For another take on the same problem, check out [jdhao's nice guide on setting up backward search in Neovim](https://jdhao.github.io/2021/02/20/inverse_search_setup_neovim_vimtex/) on both macOS and Windows.
This guide stores Neovim's server address differently than I described above: instead of launching Neovim with the `--listen /tmp/texsocket` option, it uses Neovim's default, randomly-generated server address and writes `v:servername` to a text file at `/tmp/vimtexserver.txt`, which it then reads from Skim using the `cat /tmp/vimtexserver.txt`.

#### Backward search with Vim and Skim
**TLDR**: If you want inverse search on macOS use Neovim or MacVim.

*I have not yet figured out how to set up inverse search with terminal Vim.*
But I thought I might provide a few pointers if you want to play around with this yourself.

- *Important*: Vim must be compiled with the `clientserver` option for backward search to work.
  On a command line enter `vim --version` and ensure the output includes `+clientserver` (as opposed to `-clientserver`).
  If your Vim does not have `clientserver`, a solution is to uninstall your current Vim, install MacVim (e.g. `brew install macvim`), and then use `vim` as usually.
  Even if you don't use the GUI, installing MacVim should also ship a version of Vim with `clientserver` enabled.

- From the documentation in `:help clientserver` you *should* be able to
  1. Open Vim with `vim --servername VIM myfile.tex`, or use `:call remote_startserver("VIM")` after launching Vim.
     Use `:echo v:servername` to ensure Vim's server name was set to `VIM`.

  2. In your PDF reader, use an inverse search command like
     ```sh
     vim --servername VIM --remote +{linenumber} {file}
     ```
     Translated to Skim's syntax, this would be
     ```sh
     vim --servername VIM --remote +%line "%file"
     ```
  3. Compile LaTeX documents with `synctex` enabled and trigger inverse search in Skim, as usual, with `<Cmd>+<Shift>+<Mouse-Click>`.

  But I did not get this to work when writing this series, and I would appreciate any solutions.

## Setting Up Zathura (read this on Linux)
There are three main players you will see floating around in this section:
1. Zathura's `--synctex-editor-command` option (abbreviated to `-x`), used to connect Zathura to a LaTeX source file for the purposes of inverse search.

1. Zathura's `--synctex-forward` option, used for performing forward search when calling Zathura from Vim.

1. The command-line tool [`xdotool`](https://github.com/jordansissel/xdotool), used to automatically switch focus from Zathura to Vim (so that, say, you don't have to manually switch back from Zathura to Vim to restart editing after every inverse search.)

### Implementation
First follow the steps in [Setting up Neovim for remote communication](#setting-up-neovim-for-remote-communication).

Then create `ftplugin/tex.vim` if you don't already have it, and inside add the following variables:
```vim
" Boolean-like variable to track if a Zathura instance is currently open
" and displaying the PDF file associated with the current LaTeX buffer.
" 1 means Zathura is open
" 0 means Zathura is closed
let b:zathura_open = 0   " initialize to Zathura closed

" ID of the window holding Vim as understood by xdotool.
" Used to switch focus from Zathura to Vim using xdotool.
let g:window_id = system("xdotool getactivewindow")
```
Then create script-local Vimscript function called, for example, `s:TexForwardShowZathura`, which we will use to implement forward search.
There is a lot of complicated-looking code, but the logic is simple: we are just setting correct values for Zathura's `--synctex-editor-command` and `synctex-forward` options with a bit of Vimscript string concatenation thrown in.
```vim
" The inverse search command that Zathura runs in response to Ctrl-Click,
" which just runs the local shell script `latex-linux.sh` with a few parameters.
" Note that the entire command is intentionally enclosed in double quotes.
" A human-readable version of s:inverse_command is:
" "latex-linux.sh %{input} %{line} <Vim-window-id>"
let s:inverse_command = 
      \'"${HOME}/.config/nvim/personal/inverse-search/latex-linux.sh ' .
      \ ' %{input} %{line} ' .
      \ expand(g:window_id) . '"'

function! s:TexForwardShowZathura() abort
    " A human-readable version of forward_command is:
    " --synctex-forward line:col:myfile.tex myfile.pdf
    " Get line and column numbers in LaTeX file when forward search is triggered
    let forward_command = " --synctex-forward " .
      \ line('.') . ":" .
      \ col('.') . ":" .
      \ expand('%:p') . " " .
      \ expand('%:p:r') . ".pdf"

    " If Zathura is already open.
    " Note that setting `b:zathura_open = 0` is taken care of
    " in the below jobstart call's `on_exit` handler.
    if b:zathura_open
        " Using the *synchronous* `execute` command ensures Zathura displays the
        " correct PDF line and steals focus before we call `xdotool` a few lines
        " below to switch focus back from Zathura to Vim.
        " Zathura switching its displayed line takes a couple hundred ms max, 
        # so synchronous execution is acceptable here.
        execute "!zathura " . expand(forward_command)

    " If Zathura is not yet open, set the -x (inverse search) option.
    " Since the Zathura instance must remain open indefinitely, i.e. as long
    " as we wish to have the PDF file open, asynchronous execution is essential.
    " The `on_exit` handler will allow Vim to detect when Zathura closes.
    else
      jobstart("zathura -x " . 
            \ s:inverse_command . " " .
            \ forward_command,
            \ {'on_exit': 'ZathuraExit'})

      let b:zathura_open = 1
      " Give Zathura time to open and steal focus from Vim before calling
      " `xdotool` to switch focus back from Zathura to Vim.
      sleep 250m  
    endif

    " The xdotool call finishes quickly enough to run synchronously, i.e. with `execute !`
    execute "!xdotool windowfocus " . expand(g:window_id)
    redraw!  " update Vim screen
endfunction
```
Then add the following `ZathuraExit` function, which is used as the `on_exit` callback handler associated with the `jobstart` call used to launch Zathura in the code block above.
Loosely, the `on_exit` event notifies Vim when Zathura closes, even if Zathura is not closed from Vim.
We then update the Vim variable `b:zathura_open` to reflect the terminated connection between Vim and Zathura.
See Neovim's `:help on_exit` for documentation; the Vim equivalent is `:help close_cb`.
```vim
" Callback function for use with job_start after Zathura closes.
" Simply turns off the b:zathura_open variable.
function! ZathuraExit(job_id, data, event)
  let b:zathura_open = 0
endfunction
```
As a last step in `ftplugin/tex.vim`, map the key combination `<leader>f` (or whatever else you like) to trigger forward show.
```vim
nmap <leader>f <Plug>TexForwardShow
noremap <script> <Plug>TexForwardShow <SID>TexForwardShow
noremap <SID>TexForwardShow :call <SID>TexForwardShowZathura()<CR>
```
See **TODO** reference for the theory of creating key mappings to call script-local functions.

Finally, create a shell script (this example uses `${HOME}/.config/nvim/personal/inverse-search/latex-linux.sh`, but put it wherever you want as long as you update the `s:inverse_command` accordingly) with the following content:
```sh
#!/bin/sh
# Used for inverse search from a PDF in Zathura 
# to the corresponding *.tex in Neovim on Linux.
# xdotool is used to return focus to the Vim window.
#
# SYNOPSIS
#   inverse <tex_file> <line_num> <window_id>
# ARGUMENT
#    <tex_file>
#     Path to the LaTeX file to open in Neovim
#    
#    <line_num>
#     Line number to move the cursor to in the opened LaTeX file
#    
#    <window_id>
#     Numerical ID of the window in which Vim is running
#     as returned by `xdotool getactivewindow`.
#     E.g. 10485762
nvr --remote-silent --servername=/tmp/texsocket +"${2}" "${1}"
xdotool windowfocus ${3}
```

### Documentation

#### Window manager control
Desired behavior:
- After triggering forward show in Vim, return focus from Zathura back to the terminal (in my case Alacritty) running Vim.

- After triggering inverse show in Zathura, switch focus from Zathura to the terminal running Vim

We implement this behavior with `xdotool`'s `windowfocus` command.
Using `windowfocus` requires the ID number (e.g. in the format outputed by `xdotool getactivewindow`) of the window to focus.

References: [online man page](https://man.archlinux.org/man/xdotool.1.en), [project webpage](https://www.semicomplete.com/projects/xdotool/), [GitHub page](https://github.com/jordansissel/xdotool)

Workflow:
- Use Vim's `system` function to query `xdotool getactivewindow` when switching to a buffer with the `tex` file type.
  Store the window ID in an e.g. global Vim variable `g:window_id`.
  This will return the window ID of the window holding the Vim instance containing the LaTeX file.
  Example implementation: in `ftplugin/tex.vim` add
  ```vim
  let g:window_id = system("xdotool getactivewindow")
  ```

- Use `xdotool windowfocus <window>` to focus the window holding Vim.

  Note also the possibility of switching focus back to a terminal (e.g. for the Alacritty terminal) with
  ```sh
  xdotool search --class "Alacritty" windowfocus
  ```
  But this is unreliable if you have multiple instances of the same terminal open.

#### Forward search
##### `synctex view` documentation
- Reference: `synctex help view`
- `synctex view` is a command used to implement forward search and is meant to be called by a text editor.

- Full usage is (from `synctex view help`)
  ```sh
  synctex view -i line:column:[page_hint:]input -o output [-d directory] [-x viewer-command] [-h before/offset:middle/after]
  ```
  For practical purposes, the following seems to be enough:
  ```sh
  synctex view -i line:column:input -o output [-d directory]
  ```
  where
  - `line` and `column` are 1-based integers representing the target line and column in text file
    `input` is the path to the LaTeX source file (it should match the source file's name as it appears in a compilation `*.log` file.)

  - `output` is the full path to the PDF file to be displayed 
  (called output because it is the result of compiling the source file)

  - `directory` is the directory containing the `*.synctex` file associated with LaTeX source file.
    You can omit the `-d directory` option if the `*.pdf` and `*.synctex` files have the same parent directory

  - Normally `synctex` outputs its result to `stdout`.
    The `-x viewer-command` option is used launch a PDF reader with `synctex`'s output

##### Zathura forward search documentation
```sh
zathura --synctex-forward <input> myfile.pdf
```
where `<input>` uses the same format as `synctex`'s `view -i`, which is documented in `synctex help view`

From the `SYNCTEX SUPPORT` section of `man zathura`,

> Zathura knows how to parse the output of the `synctex view` command.

> It is enough to pass the arguments to `synctex view`'s `-i` option (i.e. `line:column:[page_hint:]tex_file`) to Zathura via Zathura's `--synctex-forward` option [and Zathura will take care of the rest].

Lesson: call Zathura from Vim with
```sh
zathura --synctex-forward line:column:input.tex output.pdf
```
Note that `man zathura` does provide a forward search example, but I take a different route in this text.

#### Backward search
##### `synctex edit` documentation

- Reference: `synctex help edit`

- `synctex edit` is a command used to implement inverse search and is meant to be called by a PDF reader.

- Full usage is (from `synctex edit help`)
  ```sh
  synctex edit -o page:x:y:file [-d directory] [-x editor-command] [-h offset:context]
  ```
  What's relevant on the user's end is the `-x editor-comand` option.

  The `editor-command` should be a `printf`-like string, but that sounds scary if you don't know how `printf` works.
  Basically `synctex` gives you the following macros to work with:
  - `%{output}` is the full path to the output (PDF) document, with no extension.
  - `%{input}` is the full path to the input (LaTeX) document.
  - `%{line}` is the 0-based line number specifier; use `%{line+1}` for 1-based lines
  `%{column}` is the 0-based column number specifier; `%{column+1}` for 1-based columns.
  - `%{offset}` is the 0 based offset specifier and 
  - `%{context}` "is the context specifier of the hint". What is that?

  You can then use the macros to construct a command that opens the text editor of your choice at the desired `{line}` and `{column}`

- Note that if the `-x` option is not provided to `synctex edit`, the content of the `SYNCTEX_EDITOR` environment variable is used instead.

##### Zathura's inverse search documentation
- In Zathura inverse search is triggered with `<Ctrl><Left mouse click>`

- Open a Zathura instance with the `-x` option, which should contain, in quotes, the command the opened Zathura instance should run in response to `<Ctrl><Left mouse click>`

  The `-x` command seems to be the analog of the `-x` option in the `synctex view` command and can use the same syntax and macros.

- Here is an example from `man zathura` to give you an idea of how you could use the `-x` option:
  ```sh
  zathura -x "gvim --servername VIM --remote +%{line} %{input}" myfile.pdf
  ```
  The `-x` option holds a standard remote process call to Vim and opens the file stored in Synctex's `%{input}` macro at the line number stored in `synctex`'s `%{line}` macro using `gvim` with the `--remote` option.
