---
title: PDF Reader \| Setting up Vim for LaTeX Part 4
---

# Setting Up a PDF Reader for Writing LaTeX with Vim

This is part five in a [six part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents.
This article explains, for both macOS and Linux, how to set up an external PDF reader for displaying the PDF file associated with the LaTeX source file being edited in Vim.
<!-- for both the VimTeX plugin's built-in PDF reader interface and custom set-up of your own design. -->

## Contents of this article
<!-- vim-markdown-toc GFM -->

* [What to read in this article](#what-to-read-in-this-article)
* [Choosing a PDF Reader](#choosing-a-pdf-reader)
  * [A PDF reader on Linux](#a-pdf-reader-on-linux)
  * [A PDF reader on macOS](#a-pdf-reader-on-macos)
  * [A PDF reader on Windows](#a-pdf-reader-on-windows)
* [Cross-platform concepts](#cross-platform-concepts)
  * [Forward search and inverse search](#forward-search-and-inverse-search)
    * [Compiling with SyncTeX](#compiling-with-synctex)
  * [Inter-process communication requires a server](#inter-process-communication-requires-a-server)
  * [Getting a clientserver-enabled Vim](#getting-a-clientserver-enabled-vim)
  * [Ensure Vim starts a server](#ensure-vim-starts-a-server)
* [Using VimTeX](#using-vimtex)
  * [Zathura (read this on Linux)](#zathura-read-this-on-linux)
    * [Ensure your Zathura is SyncTeX-enabled](#ensure-your-zathura-is-synctex-enabled)
    * [Optional tip: Return focus to Vim after forward search](#optional-tip-return-focus-to-vim-after-forward-search)
  * [Skim (read this on macOS)](#skim-read-this-on-macos)
  * [Further reading](#further-reading)
* [OS-agnostic steps](#os-agnostic-steps)
  * [Setting up Neovim for remote communication](#setting-up-neovim-for-remote-communication)
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
    * [Forward search](#forward-search)
      * [`synctex view` documentation](#synctex-view-documentation)
      * [Zathura forward search documentation](#zathura-forward-search-documentation)
    * [Backward search](#backward-search-1)
      * [`synctex edit` documentation](#synctex-edit-documentation)
      * [Zathura's inverse search documentation](#zathuras-inverse-search-documentation)
* [TODO](#todo)
* [Summary](#summary)

<!-- vim-markdown-toc -->

## What to read in this article
Everyone should read:
- [Choosing a PDF Reader](#choosing-a-pdf-reader)
- [Cross-platform concepts](#cross-platform-concepts)

## Choosing a PDF Reader
The general goal in this article is to configure a PDF reader for displaying the PDF file associated with the LaTeX source file edited in Vim.
You want a PDF reader that:

- in the background, constantly listens for changes to the PDF document and automatically updates its display when the document’s contents change after compilation.
  (The alternative: manually switch applications to the PDF reader, refresh the document, and switch back to Vim for *every single compilation*.
  You would tire of this pretty quickly.
  Or I guess you could hack together a shell script to do this for you, but why bother?)
  
- Integrates with a program called SyncTeX, which makes it easy for Vim and the PDF reader to communicate with each other.

### A PDF reader on Linux
I recommend and will cover [Zathura](https://pwmt.org/projects/zathura/), under the assumption that anyone reading a multi-article Vim series will appreciate Zathura's Vim-like key bindings and text-based configurability.
VimTeX also makes configuration between Zathura and Vim very easy.
Note, however, that many more Linux-compatible PDF reader exist---see the VimTeX plugin's documentation at `:help g:vimtex_view_method` if curious.

### A PDF reader on macOS
On macOS, to the best of my knowledge, you have basically one native option meeting the above criteria: [Skim](https://skim-app.sourceforge.io/).
You can download Skim as a macOS `dmg` file from its [homepage](https://skim-app.sourceforge.io/) or from [SourceForge](https://sourceforge.net/projects/skim-app/).
The default macOS PDF reader, Preview, does not listen for document changes, nor, to the best of my knowledge, does it integrate nicely with SyncTeX.

(It is also possible to build Zathura on macOS---see the [`homebrew-zathura` GitHub page if interested](https://github.com/zegervdv/homebrew-zathura). If you choose to use `homebrew-zathura` on macOS, you should be able to follow along with the Zathura instructions for Linux.)

### A PDF reader on Windows
I have not tested it myself and will not cover it in this article (reminder of the [series prerequisites for operating system]({% link tutorials/vim-latex/prerequisites.md %})), but the SumatraPDF viewer supposedly supports both forward and backward search.
One can read more in the VimTeX plugin's documentation at `:help vimtex_viewer_sumatrapdf`.
See also `:help g:vimtex_view_method` for other PDF reader possibilities on Windows.

<!-- TODO: link to jdhao's inverse search. -->

## Cross-platform concepts
Many of the same ideas apply on both macOS and Linux.
To avoid repetition I will list these here,
and leave OS-specific implementation details for later in the article.

### Forward search and inverse search
You will hear two bits of jargon throughout this article:
- *Forward search* is the process jumping from Vim to the position in the PDF document corresponding the current cursor position in the LaTeX source file in Vim.
  In everyday language, forward search is a text editor telling a PDF reader: "hey, PDF reader, show the position in the PDF file corresponding to my current position in the LaTeX file".
  <!-- TODO: GIF -->

- *Inverse search* (also called *backward search*) is the process of switching focus from a line in the PDF document to the corresponding line in the LaTeX source file. 
  Informally, inverse search is like the user asking, "hey, PDF viewer, please take me to the position in the LaTeX source file corresponding to my current position in the PDF file".

Positions in the PDF file are linked to positions in the LaTeX source file using a utility called SyncTeX, which is implemented in a binary program called `synctex` that should ship by default with a standard TeX installation.

<!-- **Note** Vim might not create a listen address at `/tmp/texsocket` if a file `/tmp/texsocket` already exists there from a different LaTeX document. -->
<!-- In this case `v:servername` will default to something random and it will seem like backward search won't work. -->
<!-- Deleting the existing `/tmp/texsocket` should solve the problem. -->

#### Compiling with SyncTeX
For forward and backward search to work properly, your LaTeX documents must be compiled with `synctex` enabled.
This is as simple as passing the `-synctex=1` option to the `pdflatex` or `latexmk` programs when compiling your LaTeX files; VimTeX's compiler backends do this by default, and doing so manually was covered in the [previous article in this series]({% link tutorials/vim-latex/compilation.md %}).
If you are curious, you can find more `synctex` documentation at `man synctex` or by searching `man pdflatex` or `man latexmk` for `'synctex'`.

### Inter-process communication requires a server
Here is the big picture: inverse search requires one program---the PDF reader---to be able to access and open a second program---Vim---and ideally open Vim at a specific line.
This type of inter-program communication is possible because of Vim's built-in [remote procedure call (RPC) protocol](https://en.wikipedia.org/wiki/Remote_procedure_call).
The details of implementation vary between Vim and Neovim 
(see `:help remote.txt` for Vim and `:help RPC` for Neovim)
but in both cases Vim or Neovim must run a *server* that listens for and processes requests from other programs (such as a PDF reader).
In this article and in the Vim and VimTeX documentation you will hear talk about a server---what we are referring to is the server Vim/Neovim must run to communicate with a PDF reader.
Keep in mind throughout that an RPC protocol and client-server model are required under the hood for inverse search to work.

### Getting a clientserver-enabled Vim
Neovim, GVim, and MacVim come with client-server functionality by default; if you use any of these programs, lucky you.
You can skip to the next section.

If you use terminal Vim, run `vim --version`.
If the output includes `+clientserver`, your Vim version is compiled with client-server functionality enabled and can perform inverse search.
Skip to the next section.
If the output includes `-clientserver`, your Vim version does not have client-server functionality.
You will need to install a new version of Vim to use inverse search.
Getting a new version is easy:
- **On Linux:** Use your package manager of choice to install `gvim`, which will include both the GUI program GVim *and* a regular command-line version of Vim compiled with client-server functionality---you will be able to keep using regular terminal `vim` as usual.
  After installing `gvim`, check the output of `vim --version` again;
  you should now see `+clientserver`.

  Note that your package manager may notify you that `gvim` and `vim` are in conflict.
  That's normal---in this case just follow the prompts to remove `vim` and install `gvim`, which will also include a version of regular terminal `vim`.

- **On macOS:** Install MacVim (e.g. `brew install macvim`), which, like `gvim` on Linux, will include both the GUI MacVim *and* a command-line version of Vim compiled with client-server functionality.
  After installing MacVim, check the output of `vim --version` again;
  you should now see `+clientserver`.

*The rest of this article assumes you have a version of Vim with `+clientserver`*.

### Ensure Vim starts a server
Neovim, GVim, and MacVim start a server on startup automatically; if you use any of these programs, lucky you---skip to the next section.
If you use Vim, you need to ensure Vim starts a server for inverse search to work.
To do so, place the following code snippet in your `vimrc` or `ftplugin/tex.vim`:
```vim
if empty(v:servername) && exists('*remote_startserver')
  call remote_startserver('VIM')
endif
```
This code checks the built-in `v:servername` variable to see if Vim has started a server, and if it hasn't, starts a server named `VIM` if Vim's `remote_startserver` function is available (which it should be on a reasonably up-to-date version of Vim).
The above code snippet was taken from the VimTeX documentation at `:help vimtex-clientserver`, which will give you more background on starting a server for inverse search.

After adding the above code snippet to your Vim config, restart Vim and check the output of `echo v:servername`---it should output `VIM`.
Then open a LaTeX file and check the output of `:VimtexInfo`; the output should look something like this:
```sh
# If a server is successfully running:
Has clientserver: true
Servername: VIM

# If a server is not running---inverse search won't work
Has clientserver: true
Servername: undefined (vim started without --servername)
```

## Using VimTeX

### Zathura (read this on Linux)
Good news: VimTeX makes connecting Zathura and Vim/Neovim very easy.
Here is what to do:

- You will, obviously, need Zathura installed---do this with the package manager of your choice.
  Then double check that your version of Zathura supports SyncTeX---this is explained in detail in the section [Ensure your Zathura is SyncTeX-enabled](#ensure-your-zathura-is-synctex-enabled) below.

- You will need the VimTeX plugin installed. 
  Check that the VimTeX PDF viewer interface is enabled by entering `:echo g:vimtex_view_enabled`, which will print `1` if VimTeX's PDF viewer interface is enabled and `0` if it is disabled.
  (The interface is enabled by default; if `:echo g:vimtex_view_enabled` prints `0`, you have probably manually set `let g:vimtex_view_enabled = 0` somewhere in your Vim config and will have to track that down and fix it before proceeding.)
  
- Install the [`xdotool`](https://github.com/jordansissel/xdotool) program using the Linux package manager of your choice.
  (VimTeX uses `xdotool` to make forward search work properly; see `:help vimtex-view-zathura` for reference.)
  
- Place the following code in your `ftplugin/tex.vim` file:
  ```vim
  " Use Zathura as the VimTeX PDF viewer
  let g:vimtex_view_method = 'zathura'
  ```

- Use the `:VimtexView` command in Vim/Neovim to trigger forward search.
  You can either type this command manually, use the default VimTeX shortcut `<localleader>lv`, or define your own shortcut;
  to define your own shortcut place the following code in your `ftplugin/tex.vim` file:
  ```vim
  " Define a custom shortcut to trigger VimtexView
  nmap <localleader>v <plug>(vimtex-view)
  ```
  You could then use `<localleader>v` to trigger forward search---of course you could replace `<localleader>v` with whatever shortcut you prefer.

- If you are using terminal Vim, ensure Vim has started a server as described above in the section [Ensure Vim starts a server](#ensure-vim-starts-a-server).
  *Inverse search will not work if your Vim is not running a server*.
  If you are using Neovim or GVim, lucky you---these programs start a server automatically and you have nothing to worry about.
  If interested, you can check the name of the current Vim server with `echo v:servername` or by calling `:VimtexInfo` and scrolling to the `Servername:` line.

- In Zathura, use `<CTRL>-<Left-Mouse-Click>` (i.e. a left mouse click while holding the control button) to trigger inverse search, which should open Vim and switch focus to the correct line in the LaTeX source file.
  Inverse search should "just work"---this is because Zathura implements SyncTeX integration in a way (using Zathura's `--synctex-forward` and `--syntex-editor-command` options) that lets VimTeX launch Zathura with the relevant synchronization steps taken care of under the hood.
  <!-- TODO: if curious, you can see how to manually set up forward and inverse search on Zathura by scrolling down to the section on REFERENCE -->

#### Ensure your Zathura is SyncTeX-enabled
Zathura must be compiled with `libsynctex` for forward and inverse search to work properly.
(Most Linux platforms should ship a version with `libsynctex` support, but this isn't guaranteed---see the note towards the bottom of `:help vimtex-view-zathura` for more information.)
You can check that your version of Zathura has SyncTeX support using the `ldd` program, which checks for shared dependencies: just issue the following command on command line:
```sh
ldd $(which zathura) | grep libsynctex
```
If the output returns something like `libsynctex.so.2 => /usr/lib/libsynctex.so.2 (0x00007fda66e50000)`, your Zathura has SyncTeX support.
If the output is blank, your Zathura does not have SyncTeX support, and forward and inverse search will not work---you will need a new version of Zathura or a different PDF reader.

Note that VimTeX performs this check automatically and will warn you if you are using a Zathura version without SyncTeX support;
for the curious, this check is implemented in the VimTeX source code in the file `vimtex/autoload/vimtex/view/zathura.vim`, on [line 27](https://github.com/lervag/vimtex/blob/master/autoload/vimtex/view/zathura.vim#L27) at the time of writing.
See `:help g:vimtex_view_zathura_check_libsynctex` for reference.

#### Optional tip: Return focus to Vim after forward search
Depending on you window manager and/or desktop environment, window focus may switch from Vim to Zathura after performing inverse search (this happens for me on i3; YMMV).
If you prefer, you can use `xdotool` to keep focus in Vim during forward search.
Here's what to do:
- Place the following line in your `ftplugin/tex.vim`:
  ```vim
  " Get Vim's window ID for switching focus from Zathura to Vim after forward search
  let g:window_id = system("xdotool getactivewindow")
  ```
  This will, whenever you open a LaTeX file, use `xdotool` to query for an 8-digit window ID identifying the window running Vim (which is presumably the active window) and store this ID in the global Vim variable `g:window_id`.

- Then define the following Vimscript function, also in `ftplugin/tex.vim`:
  ```vim
  function! s:TexForwardShowZathura() abort
    VimtexView
    sleep 100m  " give VimtexView 100 ms to complete; tweak value as needed
    silent execute "!xdotool windowfocus " . expand(g:window_id)

    " In case the windowfocus command failed; perhaps Vim's window ID changed
    if v:shell_error
      let g:window_id = system("xdotool getactivewindow")
      silent execute "!xdotool windowfocus " . expand(g:window_id)
    endif

    redraw!
  endfunction
  ```
  This function calls `VimtexView` to execute forward search, waits 100 ms for `VimtexView` to complete using the `sleep` command, then uses `xdotool`'s `windowfocus` command to immediately refocus the window holding Vim.
  Using `silent execute` instead of just `execute` suppresses `Press ENTER or type command to continue` messages.
  Although it is hacky, I have empirically found the 100 ms wait ensures the subsequent window focus executes properly.
  A better solution might define some sort of callback that executes after `VimtexView` completes successfully---if you have a more elegant solution please let me know, and I will update my suggestion here.

  I have found that Vim's window ID occasionally changes and causes the `windowfocus` command to fail;
  although it feels like a hacky workaround, the `if v:shell_error` block uses Vim's built-in `v:shell_error` variable (see `:help v:shell_error`) to see if the previous `xdotool windowfocus` command failed, and if so gets the current window ID and retries the `windowfocus` command with the new ID.
  In my experience, this solves the problem.
  The `redraw!` command refreshes Vim's screen.
  <!-- TODO: you can read more about Vimscript functions in the Vimscript article. -->

- Finally, define a key mapping to call the `s:TexForwardShowZathura()` function by placing the following code in your `ftplugin/tex.vim`:
  ```vim
  nmap <localleader>v <Plug>TexForwardShow
  noremap <script> <Plug>TexForwardShow <SID>TexForwardShow
  noremap <SID>TexForwardShow :call <SID>TexForwardShowZathura()<CR>
  ```
  The updated `ftplugin/tex.vim` file would look something like this:
  ```vim
  " Get Vim's window ID for switching focus from Zathura to Vim after forward search
  let g:window_id = system("xdotool getactivewindow")

  function! s:TexForwardShowZathura() abort
    VimtexView
    sleep 100m  " give VimtexView 100 ms to complete; tweak value as needed
    silent execute "!xdotool windowfocus " . expand(g:window_id)

    " In case the windowfocus command failed; perhaps Vim's window ID changed
    if v:shell_error
      let g:window_id = system("xdotool getactivewindow")
      silent execute "!xdotool windowfocus " . expand(g:window_id)
    endif

    redraw!
  endfunction

  nmap <localleader>v <Plug>TexForwardShow
  noremap <script> <Plug>TexForwardShow <SID>TexForwardShow
  noremap <SID>TexForwardShow :call <SID>TexForwardShowZathura()<CR>
  ```
  You could then use `<localleader>v` in Vim's normal mode to trigger forward show (you could of course change `<localleader>v` to whatever you prefer).
  Since `s:TexForwardShowZathura()` is a script-local function, the above mapping needs to use Vim's `<SID>` mapping syntax, which might be unfamiliar;
  this syntax is explained in this series' Vimscript article.
  <!-- TODO: reference. -->

### Skim (read this on macOS)
Here is how to set up Skim to work with Vim/Neovim running VimTeX.
Some of the steps are the same as for Zathura on Linux, so excuse the repetition:
- You will, obviously, need Skim installed---you can download Skim as a macOS `dmg` file either from [the Skim homepage](https://skim-app.sourceforge.io/) or from [SourceForge](https://sourceforge.net/projects/skim-app/).
  If you already have Skim installed, upgrade to the latest version to ensure forward search works properly.

- In Skim, enable automatic document refreshing (so Skim will automatically update the displayed PDF after each compilation): open Skim and navigate to `Preference` > `Sync` and select `Check for file changes` and `Reload automatically`.

- You will need the VimTeX plugin installed. 
  Check that the VimTeX PDF viewer interface is enabled by entering `:echo g:vimtex_view_enabled`, which will print `1` if VimTeX's PDF viewer interface is enabled and `0` if it is disabled.
  (The interface is enabled by default; if `:echo g:vimtex_view_enabled` prints `0`, you have probably manually set `let g:vimtex_view_enabled = 0` somewhere in your Vim config and will have to track that down and fix it before proceeding.)
  
- Place the following code in your `ftplugin/tex.vim` file:
  ```vim
  " Use Skim as the VimTeX PDF viewer
  let g:vimtex_view_method = 'skim'
  ```
  If interested, see `:help vimtex-view-skim` for more information.

- Use the `:VimtexView` command in Vim/Neovim to trigger forward search.
  You can either type this command manually, use the default VimTeX shortcut `<localleader>lv`, or define your own shortcut;
  to define your own shortcut place the following code in your `ftplugin/tex.vim` file:
  ```vim
  " Define a custom shortcut to trigger VimtexView
  nmap <localleader>v <plug>(vimtex-view)
  ```
  You could then use `<localleader>v` to trigger forward search---of course you could replace `<localleader>v` with whatever shortcut you prefer.

  *If forward search is not working, ensure Skim is fully up to date.*
  VimTeX recently switched to a new forward search implementation (see [refactor skim viewer #2289](https://github.com/lervag/vimtex/pull/2289)) that requires an up-to-date Skim version to work properly.

- If you are using terminal Vim, ensure Vim has started a server as described above in the section [Ensure Vim starts a server](#ensure-vim-starts-a-server).
  If you are using Neovim or MacVim, lucky you---these programs start a server automatically and you have nothing to worry about.

- Configure inverse search, which is done in Skim:
  open Skim and navigate to `Preferences > Sync > PDF-TeX Sync Support`.
  Depending on your editor, proceed as follows:
  
  - **MacVim:** select `MacVim` in the `Preset` field, which will automatically populate the `Command` and `Arguments` fields with correct values.

  - **Neovim:** set the `Preset` field to `Custom`, set the `Command` field to `nvim`, and the `Arguments` field to
    ```sh
    --headless -c "VimtexInverseSearch %line '%file'"
    ```

  - **Vim:** set the `Preset` field to `Custom`, set the `Command` field to `vim`, and the `Arguments` field to
    ```sh
    -v --not-a-term -T dumb -c "VimtexInverseSearch %line '%file'"
    ```

  See `:help vimtex-synctex-inverse-search` to see where the above commands came from;
  here is a short explanation:
  - When you trigger inverse search, Skim will run the command in the `Command` field using the arguments in the `Arguments` field.
  - `%file` and `%line` are macros provided by Skim that expand to the PDF file name and line number where inverse search was triggered, respectively,
  - Both `Arguments` fields are just a sophisticated way to launch Neovim/Vim and call the `VimtexInverseSearch` function (provided by VimTeX) with the PDF line number and file name as parameters.
    
- In Skim, use `<Cmd>-<Shift>-<Left-Mouse-Click>` (i.e. a left mouse click while holding the command and shift buttons) in Skim to trigger inverse search.

<!-- Issues -->
<!-- - [Skim forward search not working on macOS 12.1 #2279](https://github.com/lervag/vimtex/issues/2279) -->
<!-- - [#1438 Crash when calling displayline: Internal table overflow](https://sourceforge.net/p/skim-app/bugs/1438/) -->


### Further reading
Suggestion: read through the VimTeX documentation beginning at `:help g:vimtex_view_enabled` and ending at `:help g:vimtex_view_zathura_check_libsynctex`.
Not all of the options will be relevant to your operating system or PDF reader, but there is plenty of interesting information and configuration options.
Here is an example: VimTeX automatically opens your PDF reader when you first compile a document, even if you have not called `:VimtexView`.
If you prefer to disable this behavior, place the following code in your `ftplugin/tex.vim`:
```vim
" Don't automatically open PDF viewer after first compilation
let g:vimtex_view_automatic = 0
```

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


## Setting up Skim (read this on macOS)
*Ensure you have an up-to-date version of Skim installed or forward search will not work.*
Explanation: macOS 12+ Monterrey caused a previous version of Skim's forward search script to stop working; see [#1438 Crash when calling displayline: Internal table overflow](https://sourceforge.net/p/skim-app/bugs/1438/).
The latest version of Skim fixes this issue.

After making sure your Skim version is up to date, enable automatic document refreshing (so Skim will automatically update the displayed PDF after each compilation) by opening Skim and navigating to `Preference` > `Sync`.
Then select `Check for file changes` and `Reload automatically`.

### Forward search with Skim
Skim ships with a shell script providing forward search---this script is called `displayline` and, for a default installation of Skim in macOS's `/Applications` folder, is found at `/Applications/Skim.app/Contents/SharedSupport/displayline`.

The `displayline` call signature is
```
displayline [-r] [-b] [-g] LINE PDFFILE [TEXSOURCEFILE]
```
You are basically telling Skim, "jump to the position in `PDFFILE` corresponding to the line number `LINE` in the LaTeX source file `TEXSOURCEFILE`".
You can read more about `displayline` at [on SourceForge](https://sourceforge.net/p/skim-app/wiki/TeX_and_PDF_Synchronization/#setting-up-your-editor-for-forward-search).
For our purposes:
- `LINE` is the integer line number (starting at 1) in the LaTeX source file from where the forward search is executed.
- `PDFFILE` is the path to the to-be-displayed PDF file (and may be given relative to the directory from which `displayline` was called).
- `TEXSOURCEFILE` is the path of the LaTeX source file from which you make the `displayline` call.
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
Suppose you wanted to use the key combination `<leader>f`, in normal mode, to trigger asynchronous forward search from the current LaTeX file.
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

First enable SyncTeX integration in Skim by opening Skim and navigating to `Preferences > Sync > PDF-TeX Sync Support`.

#### Backward search with MacVim and Skim
In case you use the GUI editor MacVim, basically everything is done for you.
Open Skim and navigate to `Preferences > Sync`.
If you use any of the text editors listed in the `Preset` field, including MacVim, just select your editor and backward search should work out of the box, assuming you compile your LaTeX documents with SyncTeX enabled.

#### Backward search with Neovim and Skim
Things on Neovim are a bit more involved, but not too bad.
First scroll back up and follow the steps for [Setting up Neovim for remote communication](#setting-up-neovim-for-remote-communication).
Then perform the following configuration in Skim:

1. Open Skim and enable SyncTeX in `Skim > Preferences > Sync > PDF-TeX Sync Support`.

1. Command line editors like Neovim and Vim require custom configuration of the `Command` and `Argument` fields.
   If you prefer the TLDR version, here are the values I use:
   - `Command`: `nvr`
   - `Argument`: `--servername=/tmp/texsocket +%line "%file"`

   And here's an explanation: When you trigger backward search in Skim, Skim runs the shell command in the `Command` field using the arguments in the `Arguments` field; in my case, if you ignore the Skim-specific `%line` and `%file` macros for a moment, this is the equivalent of opening a terminal and typing
   ```
   nvr --servername=/tmp/texsocket +%line "%file"
   ```
   About the macros: when properly configured with SyncTeX, Skim gives you the following information to work with:
   - the full path of the LaTeX source file to open in Neovim (stored in the `%file` macro), and
   - the line number in the LaTeX source file corresponding to the position you clicked in the PDF file (stored in the `%line` macro)

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
- Use Vim's `system` function to query `xdotool getactivewindow` when switching to a buffer with the LaTeX file type.
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
  The `-x` option holds a standard remote process call to Vim and opens the file stored in SyncTeX's `%{input}` macro at the line number stored in `synctex`'s `%{line}` macro using `gvim` with the `--remote` option.

## TODO
- An alternate forward show implementation on macOS and Skim using displayline and using built-in jobs feature

## Summary
**Zathura on Linux** (using VimTeX)

| Editor | Forward search works | Inverse search works | Editor keeps focus after forward search | Editor gets focus after inverse search |
| - | - | - | - | - |
| NeoVim | ✅ | ✅ | ✅[^1] | ✅ |
| Vim | ✅ | ✅ | ✅[^1] | ✅ |
| gVim | ✅ | ✅ | ✅[^1] | ❌ |

[^1]: If you use the `xdotool windowfocus` solution described in TODO, but not by default.

**Zathura on macOS** (using VimTeX)

| Editor | Forward search works | Inverse search works | Editor keeps focus after forward search | Editor gets focus after inverse search |
| - | - | - | - | - |
| NeoVim | ✅ | ✅ | ✅ | ❌ |
| Vim | ✅ | ❌ | ✅ | ❌ |
| MacVim | ✅ | ✅ | ✅ | ❌ |

**Skim on macOS** (using VimTeX)

| Editor | Forward search works | Inverse search works | Editor keeps focus after forward search | Editor gets focus after inverse search |
| - | - | - | - | - |
| NeoVim | ✅ | ✅ | ✅ | ❌ |
| Vim | ✅ | ❌ | ✅ | ❌ |
| MacVim | ✅ | ✅ | ✅ | ✅ |
