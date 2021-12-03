---
title: PDF Reader \| Setting up Vim for LaTeX Part 4
---

# Setting Up a PDF Reader for Writing LaTeX with Vim

This is part four in a [five part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents. This article explains, for both macOS and Linux, how to set up an external PDF reader for displaying the PDF file associated with the `tex` source file being edited in Vim. The article also covers how to configure forward and backward search.

## Contents of this article
<!-- vim-markdown-toc Marked -->

* [Functionality implemented in this article](#functionality-implemented-in-this-article)
* [Choosing a PDF Reader](#choosing-a-pdf-reader)
  * [On macOS](#on-macos)
  * [On Linux](#on-linux)
  * [On Windows](#on-windows)
* [Setting up Skim (read this on macOS)](#setting-up-skim-(read-this-on-macos))
  * [Forward search](#forward-search)
    * [Running shell scripts from Vim](#running-shell-scripts-from-vim)
      * [Naive implementation](#naive-implementation)
      * [Asynchronous commands with vim-dispatch](#asynchronous-commands-with-vim-dispatch)
    * [Implementing forward show](#implementing-forward-show)
  * [Backward search](#backward-search)
    * [Compiling with SyncTex](#compiling-with-synctex)
    * [The big idea: using Vim with remote procedure calls](#the-big-idea:-using-vim-with-remote-procedure-calls)
    * [Backward search with MacVim and Skim](#backward-search-with-macvim-and-skim)
    * [Backward search with Neovim and Skim](#backward-search-with-neovim-and-skim)
    * [Backward search with Vim and Skim](#backward-search-with-vim-and-skim)
* [Setting Up Zathura (read this on Linux)](#setting-up-zathura-(read-this-on-linux))

<!-- vim-markdown-toc -->

## Functionality implemented in this article
This article covers the following:

1. My suggestion for a PDF reader (Skim on macOS and Zathura on Linux) and why

1. Implementing forward search, i.e. jumping to the position in the PDF document corresponding the current cursor position in the `tex` document, triggered with a convenient keyboard shortcut from Vim.

1. Implementing inverse search, i.e. moving the cursor and switching focus from a line in the PDF document to the corresponding line in the `tex` source file, triggered by a simple click or keyboard shortcut in the PDF reader.

## Choosing a PDF Reader
The big picture here is to configure an external PDF reader to display the PDF file associated with the `tex` source file being edited in Vim. You want  PDF reader that:

- in the background, constantly listens for changes to the PDF document and automatically updates its display when the document’s contents change after compilation

  The alternative: manually switch applications to the PDF reader, refresh the document, and switch back to Vim for *every single compilation*. You would tire of this pretty quickly. (Or I guess you could hack together a shell script, but why bother?)

- supports forward search (More on this in **TODO**)
- supports SyncTeX integration, which makes backward search possible (More on this in **TODO**)

### On macOS
On macOS, to the best of my knowledge, you have basically one option meeting the above three criteria: [Skim](https://skim-app.sourceforge.io/). You can download Skim from the [homepage](https://skim-app.sourceforge.io/) or from [SourceForge](https://sourceforge.net/projects/skim-app/). macOS's default PDF reader, Preview, does not listen for document changes, nor, to the best of my knowledge, does it support SyncTeX.

### On Linux
On Linux you have a variety of options. In this article I will cover Zathura, under the assumption that anyone reading a multi-article Vim series will also appreciate Zathura's Vim-like key bindings and text-based configurability. Many more possibilities are covered in the `vimtex` plugin's documentation at `help g:vimtex_view_method`.

### On Windows
I have not tested it myself and will not cover it in this article, but supposedly the SumatraPDF viewer supports both forward and backward search. This is covered, for example, in the `vimtex` plugin's documentation at `help vimtex_viewer_sumatrapdf`. See also `help g:vimtex_view_method` for other possibilities on Windows.

<!-- TODO: link to jdhao's inverse search. -->

## Setting up Skim (read this on macOS)

First, Skim > `Preference` > `Sync` and select `Check for file changes` and `Reload automatically`.

### Forward search
Here's what forward search looks like: **TODO** GIF

Skim ships with a shell script providing forward search---this script is called `displayline` and, for a default installation of Skim into macOS's `/Applications` folder, is found at `/Applications/Skim.app/Contents/SharedSupport/displayline`.

The `displayline` call signature is
```
displayline [-r] [-b] [-g] LINE PDFFILE [TEXSOURCEFILE]
```
You are basically telling Skim, "jump to the position in `PDFFILE` corresponding to the line number `LINE` in the LaTeX source file `TEXSOURCEFILE`". You can read more about `displayline` at [on SourceForge](https://sourceforge.net/p/skim-app/wiki/TeX_and_PDF_Synchronization/#setting-up-your-editor-for-forward-search). For our purposes:
- `LINE` is the integer line number (starting at 1) in the `tex` source file from where the forward search is executed. 
- `PDFFILE` is the path to the to-be-displayed PDF file (and may be given relative to the directory from which `displayline` was called).
- `TEXSOURCEFILE` is the path of the `tex` source file from which you make the `displayline` call.
- the `-b` option highlights the jumped-to line in the PDF file in yellow. Use the `-b` option, if desired, to make it easier to see what line Skim moved to. (You can change the color in `Skim>Preferences>Display>Reading bar`).
- the `-g` option disables switching window focus to Skim after `displayline` is called; use `-g` to keep focus in your text editor.
- I don't know what the `-r` option does. The `displayline` documentation has the following to say: `-r, -revert Revert the file from disk if it was open`. Please let me know if you know know more!

For example, if run from a shell, a `displayline` call to show the PDF position associated with line 42 of the LaTeX file `myfile.tex`, using the `b` and `g` options, would read
```sh
/Applications/Skim.app/Contents/SharedSupport/displayline -bg 42 myfile.pdf myfile.tex
```
I use the full path to the displayline script, but I suppose if you add the script to your `PATH` environment variable you could use just `displayline`.


#### Running shell scripts from Vim
The idea here, just like with compilation in the [previous article]({% link tutorials/vim-latex/compilation.md %}), is to call Skim's `displayline` script, a *shell script* normally called from the command line, *from within Vim*. Additionally, the `displayline` script should run asynchronously, to not freeze up Vim.

##### Naive implementation
The simplest way to execute shell commands from Vim is Vim's `:!{command}` functionality, which is documented at `:help :!cmd`. The process is straightforward: 

1. in normal mode, enter `:` to enter Vim's command mode
1. type `!`
1. type a shell command and press Enter.

For example, running `:!pdflatex myfile.tex` from Vim's command-line mode has the same effect as running `pdflatex myfile.tex` in a terminal emulator.

##### Asynchronous commands with vim-dispatch
- Problem: Vim's built-in `:!{command}` functionality runs synchronously---this means Vim freezes until the shell command finishes executing. For execution times over a few tens of milliseconds, this delay is unacceptable. Try running `:!pdflatex %` on a LaTeX file and see for yourself (`%` is a Vim macro for the current file).

- Hacked solution: run the command in the background with `:!{command}&`. This works only on Unix systems and won't show any output. 

- Actual solution: use an *asynchronous build plugin*.

Asynchronous build plugins allow you to run shell commands asynchronously from within Vim without freezing up your editor. For this series I recommend Tim Pope's [`vim-dispatch`](https://github.com/tpope/vim-dispatch), but I have also used [skywind300](https://github.com/skywind3000)'s [asyncrun.vim](https://github.com/skywind3000/asyncrun.vim) with good results. You can install Dispatch or AsyncRun with the installation method of your choice, just like any other Vim plugin (see **TODO** prequisites). 

Both are straightforward to use---Dispatch provides a `:Start!` command while AsyncRun provides an `:AsyncRun` command; both are asynchronous equivalents of `:!`. For example:
```vim
:! pdflatex displayline 42 myfile.pdf myfile.tex  " show line 42 synchronously
:Start! displayline 42 myfile.pdf myfile.tex      " show line 42 asynchronously
:AsyncRun displayline 42 myfile.pdf myfile.tex    " show line 42 asynchronously
```

#### Implementing forward show
Suppose you wanted to use the key combination `<leader>f`, in normal mode, to trigger asynchronous forward search from the current `tex` file. Hear's what you would do:
- If using `vim-dispatch`, place the following in `ftplugin/tex.vim`:
  ```vim
  nnoremap <leader>f :execute "Start! " .
        \ "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g " .
        \ line('.') . " " .
        \ expand('%:r') . ".pdf " .
        \ expand('%')<CR>
  ```
  The macro `%` gives the current file name relative to Vim's CWD, and the modified version `%:r` gives the file name without extension. See `:help cmdline-special` and `:help filename-modifiers`. **TODO** also link to compilation or maybe just cover Vim's `filename-modifiers` in the Vimscript theory article.

  There is one potential issue: by default `vim-dispatch` tries to open a new window to show the `Start!` command's output. This is great when viewing compilation logs, but I find it disorienting for forward search, where I just want to jump to the PDF reader with minimal distractions. You can force the `Start!` command into `headless` mode, which won't open a new window, with the following configuration:
  ```vim
  let g:dispatch_no_tmux_start = 1
  let g:dispatch_no_screen_start = 1
  let g:dispatch_no_terminal_start = 1
  let g:dispatch_no_windows_start = 1
  let g:dispatch_no_iterm_start = 1
  let g:dispatch_no_x11_start = 1
  ```
  You could add this code, for example, just below the forward search key mapping to `<leader>f`. I recommend reading `:help dispatch-strategies` to see `vim-dispatch`'s runtime handlers, their order of preference, and how to disable them as shown above. You can view the handlers with `echo g:dispatch_handlers` or, if you're interested, check the `vim-dispatch` source code in `vim-dispatch/plugin/dispatch.vim` (line 88 at the time of writing).

- If using `asyncrun.vim`, place the following in `ftplugin/tex.vim`:
  ```vim
  nnoremap <leader>f :execute "AsyncRun -silent -strip " . 
        \ "/Applications/Skim.app/Contents/SharedSupport/displayline -b -g " .
        \ line('.') .
        \ " $(VIM_RELDIR)/$(VIM_FILENOEXT).pdf" .
        \ " $(VIM_RELNAME)"<CR>
  ```
  Because I prefer to silence output from forward search commands, I included the `AsyncRun` options `-silent` and `-strip` to stop the QuickFix menu from opening and to suppress AsyncRun's status messages. These are documented in `:help asyncrun-run-shell-command`, but you have to scroll down a bit.

That's it! In either case, you should now be able to access forward show with `<leader>f` in normal mode.


### Backward search
Backward search is like asking, "hey, PDF viewer, please take me to the position in the `tex` source file corresponding to my current position in the PDF file". Backward search looks something like this: **TODO** GIF.


Positions in the PDF file can be linked to positions in the `tex` source file using a utility called SyncTeX, which is implemented in a binary program called `synctex`; `synctex` should ship by default with a standard TeX installation. 

You trigger backward search in Skim using `Command`+`Shift`+`Mouse-Click` on a line in the PDF file.

**Note** Neovim will not create a listen address at `/tmp/texsocket` if a file `/tmp/texsocket` already exists there from a different LaTeX document. In this case `v:servername` will default to something random and it will seem like backward search won't work. Deleting the existing `/tmp/texsocket` should solve the problem.

#### Compiling with SyncTex
Backwards search requires that your `tex` documents are compiled *with `synctex` enabled*. This is as simple as passing the `-synctex=1` option to the `pdflatex` or `latexmk` programs when compiling your `tex` files, which is covered in the previous article, [Compiling LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %}). **TODO** link to section.

For more `synctex` documentation, see `man synctex` or search `man pdflatex` or `man latexmk` for `'synctex'`.

#### The big idea: using Vim with remote procedure calls
Here is the big picture: we need one program---the PDF reader---to be able to access and open a second program---Vim---and ideally open Vim at a specific line. This type of inter-program interaction is possible because of Vim's built-in [remote procedure call protocol](https://en.wikipedia.org/wiki/Remote_procedure_call). The RPC implementation is different in Vim and Neovim---see `:help remote.txt` for Vim and `:help RPC` for Neovim.

In practice, setting up Vim or Neovim for backward search is fairly straightforward, once you know what to do. And although the hard work is taken care of for us in the Vim/Neovim source code, it is still instructive to keep in mind that an RPC protocol and client-server model are required under the hood for backward search to work.

Since the steps in Vim and Neovim are slightly different, I explain them in two different sections below.

#### Backward search with MacVim and Skim
In case you use GUI editor MacVim, basically everything is done for you. In Skim, enable SyncTex in `Skim > Preferences > Sync > PDF-TeX Sync Support`. If you use any of the text editors listed in the `Preset` field, including MacVim, just select your editor and backward search should work out of the box, assuming you compile your LaTeX documents with SyncTex enabled.

#### Backward search with Neovim and Skim
Things on Neovim are a bit more involved, but not too bad. Here's what to do:

1. Install the `neovim-remote` Python module, which is required for Neovim to work with RPC. You can do this with `pip` just like any other Python package:
  ```
  pip install neovim-remote
  ```
  The `neovim-remote` executable is abbreviated to `nvr`, just like the `neovim` executable is abbreviated to `nvim`.

1. To use `neovim-remote` (or any Python plugin) with Neovim, you need the `pynvim` module. Install it with
   ```
   pip install pynvim
   ```
   
1. When you open a `*.tex` file with Neovim, use the following command
  ```
  nvim --listen /tmp/texsocket myfile.tex
  ```
  Explanation: Neovim starts a server when launching, and this server allows external processes to communicate with Neovim using an RPC protocol. By default, the server's listen address, (i.e. the location where programs that wish to communicate with Neovim should send commands) is randomly generated each time you open Neovim---you can view the current value with `:echo v:servername`. Try `:echo v:servername` once after launching Neovim with the `--listen /tmp/texsocket` option and once without---you should see something wierd like `/var/folders/c2/lx18_n3d1vx2jklrvj06lmbh0000gn/T/nvimUTaK3R/0` in the former case and `/tmp/texsocket` in the latter. 
  <!-- You can also check your `/tmp` directory to see if `/tmp/texsocket` was created. -->

   To communicate remotely with Neovim, Skim must know Neovim's listen address, and all that the command `nvim --listen /tmp/texsocket myfile.tex` does is launch Neovim using the file `/tmp/texsocket` as a listen address (see `:help --listen`). Using "socket" in the name is conventional because the file is a [*Unix domain socket*](https://en.wikipedia.org/wiki/Unix_domain_socket), but you could name the listen address whatever you want, as long as you can remember and reference the name later in Skim.

   Of course, you don't want to go around typing `nvim --listen /tmp/texsocket` everytime you edit a LaTeX file. I have two suggestions:
   1. Configure your file manager (you have a highly-configurable command line file manager if you're using Neovim, right?) to open `*.tex` files using the command `nvim --listen /tmp/texsocket`. For example, I use the [`vifm` file manager](https://vifm.info/) and add the following to my `~/.config/vifm/vifmrc`:
   ```vim
   filetype {*.tex},<text/tex> nvim --listen /tmp/texsocket
   ```
   This opens all `*.tex` files with the command `nvim --listen /tmp/texsocket`; other command-line file browsers should have similar functionality.

   1. Create a convenient shell alias, e.g. in your `~/.bashrc` if you use Bash, that you use for LaTeX files. For example:
   ```sh
   alias tvim='nvim --listen /tmp/texsocket'
   ```
   You would then open `*.tex` files manually with `tvim myfile.tex` instead of `nvim myfile.tex`; of course change `tvim` to whatever you want.
   
And here's what to do in Skim if using Neovim:

1. Open Skim and enable SyncTex in `Skim > Preferences > Sync > PDF-TeX Sync Support`. 

1. Command line editors like Neovim and Vim require custom configuration of the `Command` and `Argument` fields. If you're a TLDR kind of guy or gal, here are the values I use:
   - `Command`: `nvr`
   - `Argument`: `--servername=/tmp/texsocket +%line "%file"`

   And here's an explanation: When you trigger backward search in Skim, Skim runs the shell command in the `Command` field using the arguments in the `Arguments` field; in my case, if you ignore the Skim-specific `%line` and `%file` macros for a moment, this is the equivalent of opening a terminal and typing
   ```
   nvr --servername=/tmp/texsocket +%line "%file"
   ```
   About the macros: when properly configured with SyncTeX, Skim gives you the following information to work with:
   - the full path of the `tex` source file to open in Neovim (stored in the `%file` macro), and
   - the line number in the `tex` source file corresponding to the position you clicked in the PDF file (stored in the `%line` macro)

   Your job is to use the `%line` and `%file` macros to construct a shell command that opens `%file` at line number `%line` in the editor of your preference. You need the `neovim-remote` script to open Neovim remotely; this is why the `Command` field reads `nvr` and not `nvim`; using `nvim` won't work because `nvim` cannot open files remotely. Note that the `%file` macro is quoted to escape potential white spaces in file names.

   Finally, the `+%line` thing (which might evaluate in practice to, say, `+42` or `+100`) just opens Neovim at the line contained in Skim's `%line` macro. In general, `nvim +[linenum]` or `nvr +[linenum]` opens Neovim with the cursor positioned at line `linenum`---this is documented in the `OPTIONS` section of `man nvim`, but you have to scroll down a bit. For more information about `neovim-remote`, enter `nvr --help` on a command line.

**Tip: Return focus to Neovim** 

By default, in my experience, Skim does not switch focus back to terminal editors (it does for MacVim, though). To get around this, you can append `&& open -a iTerm` (if you use `iTerm` as your terminal, for example) to switch focus back to `iTerm` once the `nvr` command executes successfully. The full Skim backward search fields would then read

- `Command`: `nvr`
- `Argument`: `--servername=/tmp/texsocket +%line "%file" && open -a iTerm`

Of course replace `iTerm` with the terminal application of your choice, e.g. `open -a Alacritty` or `open -a Terminal`. (The `open -a` command is a macOS command that opens a given application.)

**Another approach:** For another take on the same problem, check out [jdhao's nice guide on setting up backward search in Neovim](https://jdhao.github.io/2021/02/20/inverse_search_setup_neovim_vimtex/) on both macOS and Windows. This guide stores Neovim's server address differently than I described above: instead of launching Neovim with the `--listen /tmp/texsocket` option, it uses Neovim's default, randomly-generated server address and writes `v:servername` to a text file at `/tmp/vimtexserver.txt`, which it then reads from Skim using the `cat /tmp/vimtexserver.txt`.

#### Backward search with Vim and Skim
**TLDR**: If you want inverse search use Neovim or MacVim.

I have not yet figured out how to set up inverse search with terminal Vim.
If you want to play around with this yourself, here are some pointers:

- Vim must be compiled with the `clientserver` option for backward search to work.
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

  But I did not get this to work when writing this series, and I would appreciate any solutions. If you are a Vim user struggling with this step, now might be as good a time as any to try out Neovim, but that's probably not too helpful.

## Setting Up Zathura (read this on Linux)
