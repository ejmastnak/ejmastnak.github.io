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
  *If you already have Skim installed, upgrade to the latest version,* which will ensure forward search works properly.

- After making sure your Skim version is up to date, enable automatic document refreshing (so Skim will automatically update the displayed PDF after each compilation) by opening Skim and navigating to `Preference` > `Sync`.
  Then select `Check for file changes` and `Reload automatically`.

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

## TODO
- Note that Vim inverse search on macOS does not work in my testing.
  If you want inverse search on macOS use Neovim or MacVim.

  Try `vim --serverlist` and notice that it is empty, even if `vim --version` lists `+clientserver` and `echo v:servername` is not empty.

  See `:help macvim-clientserver` (only available if you use MacVim's version of `vim`) and note the line
  > Server listings are made possible by the frontend (MacVim) keeping a list of all currently running servers. Thus servers are not aware of each other directly; only MacVim know which servers are running.
  
  See also [Client Server mode does not work in non-GUI macvim #657](https://github.com/macvim-dev/macvim/issues/657)

  Note that Homebrew used to offer `brew install vim --with-client-server`, but this option is no longer available.
  It may well be possible to compile a version of non-MacVim, terminal Vim from source that includes `+clientserver`, but that is beyond the scope of this tutorial, and would probably be more work than just switching to Neovim.

- Neovim and Skim inverse search using `nvr` instead of `VimtexInverseSearch`
- Neovim and Zathura inverse search using `nvr` instead of `VimtexInverseSearch`
- Forward show implementation on macOS and Skim using displayline and using built-in jobs feature. 
  Because I can.

## Summary
**Zathura on Linux** (using VimTeX)

| Editor | Forward search works | Inverse search works | Editor keeps focus after forward search | Editor gets focus after inverse search |
| - | - | - | - | - |
| Neovim | ✅ | ✅ | ✅[^1] | ✅ |
| Vim | ✅ | ✅ | ✅[^1] | ✅ |
| gVim | ✅ | ✅ | ✅[^1] | ❌ |

[^1]: If you use the `xdotool windowfocus` solution described in TODO, but not by default.

**Zathura on macOS** (using VimTeX)

| Editor | Forward search works | Inverse search works | Editor keeps focus after forward search | Editor gets focus after inverse search |
| - | - | - | - | - |
| Neovim | ✅ | ✅ | ✅ | ❌ |
| Vim | ✅ | ❌ | ✅ | ❌ |
| MacVim | ✅ | ✅ | ✅ | ❌ |

**Skim on macOS** (using VimTeX)

| Editor | Forward search works | Inverse search works | Editor keeps focus after forward search | Editor gets focus after inverse search |
| - | - | - | - | - |
| Neovim | ✅ | ✅ | ✅ | ❌ |
| Vim | ✅ | ❌ | ✅ | ❌ |
| MacVim | ✅ | ✅ | ✅ | ✅ |
