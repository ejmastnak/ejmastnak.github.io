---
title: PDF Reader \| Setting up Vim for LaTeX Part 4
---

# Setting Up a PDF Reader for Writing LaTeX with Vim

This is part five in a [six part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents.
This article explains, for both Linux and macOS, how to set up a PDF reader for displaying the PDF file associated with the LaTeX source file being edited in Vim.

## Contents of this article
<!-- vim-markdown-toc GFM -->

* [Choosing a PDF Reader](#choosing-a-pdf-reader)
  * [A PDF reader on Linux](#a-pdf-reader-on-linux)
  * [A PDF reader on macOS](#a-pdf-reader-on-macos)
  * [A PDF reader on Windows](#a-pdf-reader-on-windows)
* [Summary: What works on what platform](#summary-what-works-on-what-platform)
    * [Zathura on Linux (tested with i3 on Arch)](#zathura-on-linux-tested-with-i3-on-arch)
    * [Skim on macOS](#skim-on-macos)
    * [Zathura on macOS](#zathura-on-macos)
* [Cross-platform concepts](#cross-platform-concepts)
  * [Forward search and inverse search](#forward-search-and-inverse-search)
  * [Compiling with SyncTeX](#compiling-with-synctex)
  * [Inter-process communication requires a server](#inter-process-communication-requires-a-server)
  * [Ensuring you have a clientserver-enabled Vim](#ensuring-you-have-a-clientserver-enabled-vim)
    * [Caveat: MacVim's terminal Vim cannot perform inverse search](#caveat-macvims-terminal-vim-cannot-perform-inverse-search)
  * [Ensure Vim starts a server (only for terminal Vim on Linux)](#ensure-vim-starts-a-server-only-for-terminal-vim-on-linux)
* [Zathura (read this on Linux)](#zathura-read-this-on-linux)
  * [Ensure your Zathura is SyncTeX-enabled](#ensure-your-zathura-is-synctex-enabled)
  * [Optional tip: Return focus to Vim/Neovim after forward search](#optional-tip-return-focus-to-vimneovim-after-forward-search)
  * [Optional tip: Return focus to gVim after forward and inverse search](#optional-tip-return-focus-to-gvim-after-forward-and-inverse-search)
* [Skim (read this on macOS)](#skim-read-this-on-macos)
* [Bonus: Zathura on macOS](#bonus-zathura-on-macos)
  * [Building Zathura on macOS](#building-zathura-on-macos)
  * [Setting up Zathura on macOS](#setting-up-zathura-on-macos)
* [Fixing focus loss problems on macOS](#fixing-focus-loss-problems-on-macos)
  * [Returning focus to Neovim after inverse search on macOS](#returning-focus-to-neovim-after-inverse-search-on-macos)
  * [Returning focus to MacVim after inverse search on macOS](#returning-focus-to-macvim-after-inverse-search-on-macos)
* [Further reading](#further-reading)
* [Footnotes](#footnotes)

<!-- vim-markdown-toc -->

## Choosing a PDF Reader
You want a PDF reader that:

- In the background, constantly listens for changes to the PDF document and automatically updates its display when the document’s contents change after compilation.
  (The alternative: manually switch applications to the PDF reader, refresh the document, and switch back to Vim after *every single compilation*.
  You would tire of this pretty quickly.
  Or I guess you could hack together a shell script to do this for you, but why bother?)
  
- Integrates with a program called SyncTeX, which makes it easy for Vim and the PDF reader to communicate with each other---SyncTeX makes forward and inverse search possible.

### A PDF reader on Linux
I recommend and will cover [Zathura](https://pwmt.org/projects/zathura/), under the assumption that anyone reading a multi-article Vim series will appreciate Zathura's Vim-like key bindings and text-based configurability.
The VimTeX plugin also makes configuration between Zathura and Vim very easy.
Note, however, that many more Linux-compatible PDF readers exist---see the VimTeX plugin's documentation at `:help g:vimtex_view_method` if curious.

### A PDF reader on macOS
The canonical option on macOS is [Skim](https://skim-app.sourceforge.io/), which you can download as a macOS `dmg` file from its [homepage](https://skim-app.sourceforge.io/) or from [SourceForge](https://sourceforge.net/projects/skim-app/).
(The default macOS PDF reader, Preview, does not listen for document changes, nor, to the best of my knowledge, does it integrate nicely with SyncTeX.)

Good news: it is also possible to build Zathura on macOS---see the [`homebrew-zathura` GitHub page](https://github.com/zegervdv/homebrew-zathura) if interested---so I have included a section for setting up Zathura on macOS at the end of this article.

### A PDF reader on Windows
I have not tested it myself and will not cover it in this article (reminder of the [series prerequisites for operating system]({% link tutorials/vim-latex/prerequisites.md %})), but the SumatraPDF viewer supposedly supports both forward and backward search.
One can read more in the VimTeX plugin's documentation at `:help vimtex_viewer_sumatrapdf`.
See also `:help g:vimtex_view_method` for other PDF reader possibilities on Windows.

## Summary: What works on what platform
I tested 9 combinations of editor, OS, and PDF reader when preparing this article, and the results are summarized in the table below---the more green check marks the better.

**Recommendations based on my testing:**
- If you have a choice of editor, use Neovim---everything works on every OS, potentially with a few small work-arounds.
  This is because Neovim's built-in implementation of the remote procedure call (RPC) protocol ensures inverse search works reliably on all platforms.
  Vim has a different implementation of RPC and must be specially compiled with the `+clientserver` option to ensure inverse search works.
  This is non-trivial on macOS; 
  if you use terminal Vim on macOS, you will either have to sacrifice inverse search or perform some compiling-from-source wizardry beyond the scope of this series.
- If you have a choice of OS, use Linux---nearly everything works on both Vim and Neovim.

#### Zathura on Linux (tested with i3 on Arch)

| Editor | Forward search works | Inverse search works | Editor keeps focus after forward search | Focus returns to editor after inverse search |
| - | - | - | - | - |
| Neovim | ✅ | ✅ | ✅[^1] | ✅ |
| Vim | ✅ | ✅ | ✅[^1] | ✅ |
| gVim | ✅ | ✅ | ✅[^2] | ✅[^2] |

[^1]: If you use the `xdotool windowfocus` solution described in [Optional tip: Return focus to Vim/Neovim after forward search](#optional-tip-return-focus-to-vimneovim-after-forward-search).
[^2]: If you use the `xdotool windowfocus` solution described in [Optional tip: Return focus to gVim after forward and inverse search](#optional-tip-return-focus-to-gvim-after-forward-and-inverse-search).

#### Skim on macOS

| Editor | Forward search works | Inverse search works | Editor keeps focus after forward search | Focus returns to editor after inverse search |
| - | - | - | - | - |
| Neovim | ✅ | ✅ | ✅ | ✅[^3] |
| Vim | ✅ | ❌ | ✅ | ❌ |
| MacVim | ✅ | ✅ | ✅ | ✅ |

#### Zathura on macOS

| Editor | Forward search works | Inverse search works | Editor keeps focus after forward search | Focus returns to editor after inverse search |
| - | - | - | - | - |
| Neovim | ✅ | ✅ | ✅ | ✅[^3] |
| Vim | ✅ | ❌ | ✅ | ❌ |
| MacVim | ✅ | ✅ | ✅ | ✅[^4] |


[^3]: If you use the `open -a TERMINAL` solution described in [Optional tip: Return focus to Neovim after inverse search](#optional-tip-return-focus-to-neovim-after-inverse-search).
[^4]: If you use the `open -a MacVim` solution described in [Optional tip: Return focus to MacVim after inverse search](#optional-tip-return-focus-to-macvim-after-inverse-search).

## Cross-platform concepts
Many of the same ideas apply on both macOS and Linux.
To avoid repetition I will list these here,
and leave OS-specific implementation details for later in the article.

### Forward search and inverse search
You will hear two bits of jargon throughout this article:
- *Forward search* is the process jumping from Vim to the position in the PDF document corresponding the current cursor position in the LaTeX source file in Vim.
  In everyday language, forward search is a text editor telling a PDF reader: "hey, PDF reader, display the position in the PDF file corresponding to my current position in the LaTeX file".
  <!-- TODO: GIF -->

- *Inverse search* (also called *backward search*) is the process of switching focus from a line in the PDF document to the corresponding line in the LaTeX source file. 
  Informally, inverse search is like the user asking, "hey, PDF viewer, please take me to the position in the LaTeX source file corresponding to my current position in the PDF file".

Positions in the PDF file are linked to positions in the LaTeX source file using a utility called SyncTeX, which is implemented in a binary program called `synctex` that should ship by default with a standard TeX installation.

<!-- **Note** Vim might not create a listen address at `/tmp/texsocket` if a file `/tmp/texsocket` already exists there from a different LaTeX document. -->
<!-- In this case `v:servername` will default to something random and it will seem like backward search won't work. -->
<!-- Deleting the existing `/tmp/texsocket` should solve the problem. -->

### Compiling with SyncTeX
For forward and backward search to work properly, your LaTeX documents must be compiled with `synctex` enabled.
This is as simple as passing the `-synctex=1` option to the `pdflatex` or `latexmk` programs when compiling your LaTeX files.
VimTeX's compiler backends do this by default, and doing so manually was covered in the [previous article in this series]({% link tutorials/vim-latex/compilation.md %}).
If you are curious, you can find more `synctex` documentation at `man synctex` or by searching `man pdflatex` or `man latexmk` for `'synctex'`.

### Inter-process communication requires a server
Here is the big picture: inverse search requires one program---the PDF reader---to be able to access and open a second program---Vim---and ideally open Vim at a specific line.
This type of inter-program communication is possible because of Vim's built-in [remote procedure call (RPC) protocol](https://en.wikipedia.org/wiki/Remote_procedure_call).
The details of implementation vary between Vim and Neovim 
(see `:help remote.txt` for Vim and `:help RPC` for Neovim),
but in both cases Vim or Neovim must run a *server* that listens for and processes requests from other programs (such as a PDF reader).
In this article and in the Vim and VimTeX documentation you will hear talk about a server---what we are referring to is the server Vim/Neovim must run to communicate with a PDF reader.
Keep in mind throughout that an RPC protocol and client-server model are required under the hood for inverse search to work.

### Ensuring you have a clientserver-enabled Vim
Neovim, gVim, and MacVim come with client-server functionality by default; if you use any of these programs, lucky you.
You can skip to the next section.

If you use terminal Vim, run `vim --version`.
If the output includes `+clientserver`, your Vim version is compiled with client-server functionality and ~~can~~ might be able to perform inverse search---see the [macOS caveat below](#caveat-macvims-terminal-vim-cannot-perform-inverse-search).
If the output includes `-clientserver`, your Vim version does not have client-server functionality.
You will need to install a new version of Vim to use inverse search.
Getting a `+clientserver` version of Vim is easy on Linux and beyond the scope of this article on macOS:

- **On Linux:** Use your package manager of choice to install `gvim`, which will include both the GUI program gVim *and* a regular command-line version of Vim compiled with client-server functionality---you will be able to keep using regular terminal `vim` as usual.
  After installing `gvim`, check the output of `vim --version` again;
  you should now see `+clientserver`.

  Note that your package manager may notify you that `gvim` and `vim` are in conflict.
  That's normal---in this case just follow the prompts to remove `vim` and install `gvim`, which will also include a version of regular terminal `vim`.

- **On macOS:** You're out of luck---at least I don't know enough to be of help.
  Use Neovim or MacVim if you want inverse search to work, and read the caveat below for more information.

*The rest of this article assumes you have a version of Vim with `+clientserver`*.

#### Caveat: MacVim's terminal Vim cannot perform inverse search
Here is the tricky part: if you install MacVim (e.g. `brew install --cask macvim` or by downloading MacVim from the [MacVim website](https://macvim-dev.github.io/macvim/)), the output of `vim --version` may well show `+clientserver`.
But this is false advertising, and confused me for quite some time while writing this guide!

Here is my understanding of the issue: because of how MacVim's version of terminal Vim handles servers, even if regular terminal Vim is started with a server (using e.g. `vim --servername VIM myfile.tex`) and `:echo v:servername` returns `VIM`, the server is useless because programs other than MacVim won't be aware of it.
Quoting from `:help macvim-clientserver` (only available if you use MacVim's version of `vim`; emphasis mine):
> Server listings are made possible by the frontend (MacVim) keeping a list of all currently running servers. *Thus servers are not aware of each other directly; only MacVim know which servers are running.*

You can easily test this for yourself on macOS:
1. Install MacVim with `brew install --cask macvim`.
1. Run `vim --version` and note that the output includes `+clientserver`
1. Start Vim with `vim --servername VIM myfile.tex` and note that `:echo v:servername` returns `VIM`, suggesting client-server functionality will work.
1. Now here is the catch: open another terminal, run `vim --listservers`, and notice that the result is blank!
   In other words, even though the Vim instance editing `myfile.tex` is running a server, this server is not visible to the outside world, and effectively useful for the purposes of inverse search.

See the GitHub issue [Client Server mode does not work in non-GUI macvim #657](https://github.com/macvim-dev/macvim/issues/657) for a longer discussion of this problem.

Note that Homebrew used to offer `brew install vim --with-client-server`, but this option is no longer available.
It may well be possible to compile a version of terminal Vim from source that includes `+clientserver`, and, in combination with XQuartz, get inverse search to work on macOS using terminal Vim.
But that is beyond the scope of this tutorial, and would probably be more work than just switching to GUI MacVim or terminal Neovim, both of which support inverse search on macOS.

### Ensure Vim starts a server (only for terminal Vim on Linux)
Neovim, gVim, and MacVim start a server on startup automatically; if you use any of these programs, lucky you---feel free to skip to the next section.
If you use a [`+clientserver`-enabled terminal Vim](#ensuring-you-have-a-clientserver-enabled-vim) on Linux, place the following code snippet in your `vimrc` or `ftplugin/tex.vim`:
```vim
" This will only work if `vim --version` includes `+clientserver`!
if empty(v:servername) && exists('*remote_startserver')
  call remote_startserver('VIM')
endif
```
This code checks the built-in `v:servername` variable to see if Vim has started a server, and if it hasn't, starts a server named `VIM` if Vim's `remote_startserver` function is available (which it should be on a reasonably up-to-date version of Vim).
Starting the server makes inverse search possible.
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
Reminder: on macOS, MacVim's version of terminal Vim can misleadingly display both `Has clientserver: true` and `Servername: VIM`, but inverse search still won't work---[see the caveat above](#caveat-macvims-terminal-vim-cannot-perform-inverse-search).

*That's all for the cross-platform concepts. Let's set up a PDF reader!*

## Zathura (read this on Linux)
*If you use macOS, scroll down to the section on [configuring Skim](#skim-read-this-on-macos) or [setting up Zathura on macOS](#bonus-zathura-on-macos).*

Good news: VimTeX makes connecting Zathura and Vim/Neovim/gVim very easy.
Here is what to do:

- You will, obviously, need Zathura installed---do this with the package manager of your choice.
  Then double check that your version of Zathura supports SyncTeX---which I explain below in the dedicated section [Ensure your Zathura is SyncTeX-enabled](#ensure-your-zathura-is-synctex-enabled).

- You will need the VimTeX plugin installed. 
  Double-check that VimTeX's PDF viewer interface is enabled by entering `:echo g:vimtex_view_enabled` in Vim.
  ```vim
  :echo g:vimtex_view_enabled  " Enter this in Vim's command mode
  > 1  " VimTeX's PDF viewer interface is enabled!
  > 0  " VimTeX's PDF viewer interface is disabled---you'll have to enable it.
  ```
  Note that VimTeX's PDF viewer interface is enabled by default; if `:echo g:vimtex_view_enabled` prints `0`, you have probably manually set `let g:vimtex_view_enabled = 0` somewhere in your Vim config and will have to track that down and remove it before proceeding.
  
- Install the [`xdotool`](https://github.com/jordansissel/xdotool) program using the Linux package manager of your choice.
  (VimTeX uses `xdotool` to make forward search work properly; see `:help vimtex-view-zathura` for reference.)
  
- Place the following code in your `ftplugin/tex.vim` file:
  ```vim
  " Use Zathura as the VimTeX PDF viewer
  let g:vimtex_view_method = 'zathura'
  ```
  This line of code lets VimTeX know that you plan on using Zathura as your PDF reader.

- Use the `:VimtexView` command in Vim/Neovim to trigger forward search.
  You can either type this command manually, use the default VimTeX shortcut `<localleader>lv`, or define your own shortcut.
  To define your own shortcut place the following code in your `ftplugin/tex.vim` file:
  ```vim
  " Define a custom shortcut to trigger VimtexView
  nmap <localleader>v <plug>(vimtex-view)
  ```
  You could then use `<localleader>v` to trigger forward search---of course you could replace `<localleader>v` with whatever shortcut you prefer.

  Tip: depending on your window manager, Vim might lose focus after forward search.
  For an easy way to keep focus in Vim, scroll down to the section [Optional tip: Return focus to Vim/Neovim after forward search](#optional-tip-return-focus-to-vimneovim-after-forward-search).

- At the risk of belaboring the point, double-check your Vim is running a server by calling `:VimtexInfo` and scrolling to the `Servername` line.
  The output should read
  ```sh
  # If a server is successfully running:
  Has clientserver: true
  Servername: /tmp/nvimQb417s/0  # typical Neovim output
  Servername: VIM                # typical Vim output
  Servername: GVIM               # typical gVim output

  # If a server is not running---inverse search won't work
  Servername: undefined (vim started without --servername)
  ```
  If Vim is not running a server (which will probably only occur on terminal Vim), inverse search won't work. Scroll back up to the section [Ensure Vim starts a server (only for terminal Vim on Linux)](#ensure-vim-starts-a-server-only-for-terminal-vim-on-linux).

- In Zathura, use `<Ctrl>-<Left-Mouse-Click>` (i.e. a left mouse click while holding the control key) to trigger inverse search, which should open Vim and switch focus to the correct line in the LaTeX source file.
  Inverse search should "just work"---this is because Zathura implements SyncTeX integration in a way (using Zathura's `--synctex-forward` and `--syntex-editor-command` options) that lets VimTeX launch Zathura with the relevant synchronization steps taken care of under the hood.
  <!-- TODO: if curious, you can see how to manually set up forward and inverse search on Zathura by scrolling down to the section on REFERENCE -->

### Ensure your Zathura is SyncTeX-enabled
Zathura must be compiled with `libsynctex` for forward and inverse search to work properly.
Most Linux platforms should ship a version with `libsynctex` support and this shouldn't be a problem for you, but it isn't 100% guaranteed---see the note towards the bottom of `:help vimtex-view-zathura` for more information.
You can check that your version of Zathura has SyncTeX support using the `ldd` program, which checks for shared dependencies;
just issue the following command on the command line:
```sh
# List all of Zathura's shared dependencies and search the output for libsynctex
ldd $(which zathura) | grep libsynctex
```
If the output returns something like `libsynctex.so.2 => /usr/lib/libsynctex.so.2 (0x00007fda66e50000)`, your Zathura has SyncTeX support.
If the output is blank, your Zathura does not have SyncTeX support, and forward and inverse search will not work---you will need a new version of Zathura or a different PDF reader.

Note that VimTeX performs this check automatically and will warn you if your Zathura version lacks SyncTeX support;
for the curious, this check is implemented in the VimTeX source code in the file `vimtex/autoload/vimtex/view/zathura.vim`, on [line 27](https://github.com/lervag/vimtex/blob/master/autoload/vimtex/view/zathura.vim#L27) at the time of writing.
See `:help g:vimtex_view_zathura_check_libsynctex` for reference.

### Optional tip: Return focus to Vim/Neovim after forward search
**Relevant editors:** Vim and Neovim used with Zathura on Linux (for resolving gVim focus problems scroll down)

Depending on your window manager and/or desktop environment, Vim may lose focus after performing forward search (this happens for me on i3 with both Vim and Neovim; YMMV).
If you prefer to keep focus in Vim, you can use `xdotool` and some VimTeX autocommands to solve the problem.
Here's what to do:
1. Place the following line in your `ftplugin/tex.vim`:
   ```vim
   " Get Vim's window ID for switching focus from Zathura to Vim using xdotool.
   " Only set this variable once for the current Vim instance.
   if !exists("g:vim_window_id")
     let g:vim_window_id = system("xdotool getactivewindow")
   endif
   ```
   Whenever you open a LaTeX file, this code will use `xdotool` to query for an 8-digit window ID identifying the window running Vim (which is presumably the active window) and store this ID in the global Vimscript variable `g:vim_window_id`.
   The `if !exists()` block only sets the `g:vim_window_id` variable if it has not yet been set for the current Vim instance.

1. Then define the following Vimscript function, also in `ftplugin/tex.vim`:
   ```vim
   function! s:TexFocusVim() abort
     " Give window manager time to recognize focus moved to Zathura;
     " tweak the 200m as needed for your hardware and window manager.
     sleep 200m  

     " Refocus Vim and redraw the screen
     silent execute "!xdotool windowfocus " . expand(g:vim_window_id)
     redraw!
   endfunction
   ```
   This function calls `VimtexView` to execute forward search, waits a few hundred milliseconds to let the window manager recognize focus has moved to Zathura,
   then uses `xdotool`'s `windowfocus` command to immediately refocus the window holding Vim.
   Using `silent execute` instead of just `execute` suppresses `Press ENTER or type command to continue` messages, although you may want to start with just `execute` for debugging purposes.
   Although it is hacky, I have empirically found the `sleep 200m` wait ensures the subsequent window focus executes properly (you may want to tweak the exact sleep time for your hardware and window manager).
   The `redraw!` command refreshes Vim's screen.
   <!-- TODO: you can read more about Vimscript functions in the Vimscript article. -->

1. Finally, define the following Vimscript autocommand group in your `ftplugin/tex.vim`:
   ```vim
   augroup vimtex_event_focus
     au!
     au User VimtexEventView call s:TexFocusVim()
   augroup END
   ```
   The above autocommand runs the above-defined refocus function `s:TexFocusVim()` in response to the VimTeX event `VimtexEventView`, which triggers whenever `VimtexView` completes (see `:help VimtexEventView` for documentation.).
   In practice, this refocuses Vim after every forward search.

### Optional tip: Return focus to gVim after forward and inverse search
**Relevant editor:** gVim used with Zathura on Linux

From my testing (using the i3 window manager; YMMV) gVim lost focus after forward search and failed to regain focus after inverse search.
Here is how to fix both problems (some steps are the same as for terminal Vim/Neovim above, in which case I will refer to the above descriptions to avoid repetition):

1. Place the following line in your `ftplugin/tex.vim`:
   ```vim
   " Get Vim's window ID for switching focus from Zathura to Vim using xdotool.
   " Only set this variable once for the current Vim instance.
   if !exists("g:vim_window_id")
     let g:vim_window_id = system("xdotool getactivewindow")
   endif
   ```
   For an explanation, see the analogous step for Vim/Neovim above.

1. Then define the following Vimscript function, also in `ftplugin/tex.vim`:
   ```vim
   function! s:TexFocusVim(delay_ms) abort
     " Give window manager time to recognize focus 
     " moved to PDF viewer before focusing Vim.
     let delay = a:delay_ms . "m"
     execute 'sleep ' . delay
     execute "!xdotool windowfocus " . expand(g:vim_window_id)
     redraw!
   endfunction
   ```
   This function plays as similar role to the one in the analogous step for Vim/Neovim (see above for an explanation), but allows for a variable sleep time using the `delay_ms` argument, which is the number of milliseconds passed to Vim's `sleep` command.
   The function uses a variable sleep time because (at least in my testing) post-inverse-search refocus does not require any delay to work properly, while post-forward-search refocus does.

1. Finally, define the following Vimscript autocommand group in your `ftplugin/tex.vim`:
   ```vim
   augroup vimtex_event_focus
     au!
     " Post-forward-search refocus with 200ms delay---tweak as needed
     au User VimtexEventView call s:TexFocusVim(200)

     " Only perform post-inverse-search refocus on gVim; delay unnecessary
     if has("gui_running")
       au User VimtexEventViewReverse call s:TexFocusVim(0)
     endif
   augroup END
   ```
   The events `VimtexEventView` and `VimtexEventViewReverse`, conveniently provided by VimTeX, trigger whenever `VimtexView` and `VimtexInverseSearch` complete, respectively.
   The above autocommands run the above-defined refocus function `s:TexFocusVim()` after every execution of forward search using `VimtexView` or inverse search using `VimtexInverseSearch`.
   See `:help VimtexEventView` and `:help VimtexEventViewReverse` for documentation.

   Again, you may want to tweak the forward search delay time (somewhere from from 50ms to 300ms should suit most users) until refocus works properly on your window manager and hardware.

## Skim (read this on macOS)
*It is also possible to use Zathura on macOS; if you would prefer this, scroll down to the section [Bonus: Zathura on macOS](#bonus-zathura-on-macos).*

Here is how to set up Skim to work with Vim/Neovim running VimTeX.
Some of the steps are the same as for Zathura on Linux, so excuse the repetition:
- You will, obviously, need Skim installed---you can download Skim as a macOS `dmg` file either from [the Skim homepage](https://skim-app.sourceforge.io/) or from [SourceForge](https://sourceforge.net/projects/skim-app/).
  *If you already have Skim installed, upgrade to the latest version,* which will ensure forward search works properly.

- After making sure your Skim version is up to date, enable automatic document refreshing (so Skim will automatically update the displayed PDF after each compilation) by opening Skim and navigating to `Preference` > `Sync`.
  Then select `Check for file changes` and `Reload automatically`.

- You will need the VimTeX plugin installed. 
  Double-check that VimTeX's PDF viewer interface is enabled by entering `:echo g:vimtex_view_enabled` in Vim.
  ```vim
  :echo g:vimtex_view_enabled  " Enter this in Vim's command mode
  > 1  " VimTeX's PDF viewer interface is enabled!
  > 0  " VimTeX's PDF viewer interface is disabled---you'll have to enable it.
  ```
  Note that VimTeX's PDF viewer interface is enabled by default; if `:echo g:vimtex_view_enabled` prints `0`, you have probably manually set `let g:vimtex_view_enabled = 0` somewhere in your Vim config and will have to track that down and remove it before proceeding.

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
  <!-- - [Skim forward search not working on macOS 12.1 #2279](https://github.com/lervag/vimtex/issues/2279) -->
  <!-- - [#1438 Crash when calling displayline: Internal table overflow](https://sourceforge.net/p/skim-app/bugs/1438/) -->

- Configure inverse search:
  first open Skim and navigate to `Preferences > Sync ` and select `PDF-TeX Sync Support`.
  Then, depending on your editor, proceed as follows:
  
  - **MacVim:** select `MacVim` in the `Preset` field, which will automatically populate the `Command` and `Arguments` fields with correct values.

  - **Neovim:** set the `Preset` field to `Custom`, set the `Command` field to `nvim`, and the `Arguments` field to
    ```sh
    --headless -c "VimtexInverseSearch %line '%file'"
    ```
    The above command comes from `:help vimtex-synctex-inverse-search`;
    here is a short explanation:
    - `%file` and `%line` are macros provided by Skim that expand to the PDF file name and line number where inverse search was triggered, respectively.
    - When you trigger inverse search, Skim will run the command in the `Command` field using the arguments in the `Arguments` field.
    - The `Arguments` field is just a sophisticated way to launch Neovim and call VimTeX's `VimtexInverseSearch` function with the PDF line number and file name as parameters (the `-c` option runs a command when starting Neovim).

  - **Vim:** Inverse search won't work on macOS, at least as far as I have been able to figure out---for details, scroll back up to [Caveat: MacVim's terminal Vim cannot perform inverse search](#caveat-macvims-terminal-vim-cannot-perform-inverse-search).
    
- In Skim, use `<Cmd>-<Shift>-<Left-Mouse-Click>` (i.e. a left mouse click while holding the command and shift keys) in Skim to trigger inverse search.
  
  Note: during my testing, Neovim failed to regain focus after inverse search;
  if you would prefer for Neovim to focus after inverse search, scroll down to [Returning focus to Neovim after inverse search on macOS](#returning-focus-to-neovim-after-inverse-search-on-macos).

## Bonus: Zathura on macOS
It is possible to use Zathura on macOS without too much difficulty thanks to the Homebrew formulae provided by [github.com/zegervdv/homebrew-zathura](https://github.com/zegervdv/homebrew-zathura).
Building Zathura is described in the VimTeX documentation at `:help vimtex-faq-zathura-macos`, and I can confirm the process works (at least on macOS 12.1) from my testing while preparing this article.

### Building Zathura on macOS
Quoting more or less directly from `:help vimtex-faq-zathura-macos`, here is how to build Zathura on macOS:
1. Check if you already have Zathura installed using e.g. `which zathura`.
   If you have a Zathura installed, I recommend uninstalling it and repeating from scratch to ensure all dependencies are correctly sorted out.

1. If needed, uninstall your existing Zathura and related libraries with the following code:
   ```sh
   # Remove symlinks
   brew unlink zathura-pdf-poppler
   # or use `brew unlink zathura-pdf-mupdf` if you have mupdf installed
   brew unlink zathura
   brew unlink girara

   # Uninstall
   brew uninstall zathura-pdf-mupdf
   brew uninstall zathura
   brew uninstall girara
    ```

1. Zathura needs `dbus` to work properly;
   install it with `brew install dbus`, or, if it is already installed, reinstall it (this seems necessary for some unknown reason): `brew reinstall dbus`.

1. Set you `dbus` session address by placing the following in your shell's configuration file (e.g. `.bashrc`, `.zshrc`, etc.)
   ```sh
   export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET" 
   ```
1. Change the value of `<auth><\auth>` in
  `/usr/local/opt/dbus/share/dbus-1/session.conf` from `EXTERNAL` to `DBUS_COOKIE_SHA1`.

1. Run `brew services start dbus`.

1. Install the most recent version of Zathura (i.e. HEAD):
   ```sh
   brew tap zegervdv/zathura
   brew install girara --HEAD
   brew install zathura --HEAD --with-synctex
   brew install zathura-pdf-poppler
   mkdir -p $(brew --prefix zathura)/lib/zathura
   ln -s $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
   ```
   Notes:
   - You might be prompted by Homebrew to install the Apple Command Line Tools before you can complete `brew install girara --HEAD`.
     If so, just follow Homebrew's suggestion (which will probably be something along the lines of `xcode-select --install`), then retry  `brew install girara --HEAD`.
   - Ensure you use `brew install zathura --HEAD --with-synctex` to get a Zathura with Synctex support;
   the `hombrew-zathura` GitHub page only suggests `brew install zathura --HEAD`.
   
1. Reboot and enjoy Zathura.

For the original GitHub discussion that produced the instructions in `:help vimtex-faq-zathura-macos`, see the GitHub issue [Viewer cannot find Zathura window ID on macOS #1737](https://github.com/lervag/vimtex/issues/1737#issuecomment-759953886).

### Setting up Zathura on macOS
Here is how to set up Zathura on macOS (many steps are similar to those for [setting up Zathura on Linux](#zathura-read-this-on-linux); please excuse any repetition):
- Install the [`xdotool`](https://github.com/jordansissel/xdotool) program with `brew install xdotool`.
  (VimTeX uses `xdotool` to make forward search work properly; see `:help vimtex-view-zathura` for reference.)
  
- Place the following code in your `ftplugin/tex.vim` file:
  ```vim
  " Use Zathura as the VimTeX PDF viewer
  let g:vimtex_view_method = 'zathura'
  ```
  This line of code lets VimTeX know that you plan on using Zathura as your PDF reader.

- Use the `:VimtexView` command in Vim/Neovim to trigger forward search.
  You can either type this command manually, use the default VimTeX shortcut `<localleader>lv`, or define your own shortcut.
  To define your own shortcut place the following code in your `ftplugin/tex.vim` file:
  ```vim
  " Define a custom shortcut to trigger VimtexView
  nmap <localleader>v <plug>(vimtex-view)
  ```
  You could then use `<localleader>v` to trigger forward search---of course you could replace `<localleader>v` with whatever shortcut you prefer.

- In Zathura, use `<Ctrl>-<Left-Mouse-Click>` (i.e. a left mouse click while holding the control key) to trigger inverse search, which should open Vim and switch focus to the correct line in the LaTeX source file.
  
  Note: during my testing, I found that focus failed to return to both Neovim and MacVim after inverse search on Zathura.
  To fix these issues, depending on your editor, scroll down to one of:
  - [Returning focus to Neovim after inverse search on macOS](#returning-focus-to-neovim-after-inverse-search-on-macos)
  - [Returning focus to MacVim after inverse search on macOS](#returning-focus-to-macvim-after-inverse-search-on-macos)

## Fixing focus loss problems on macOS
This section gives two fixes for returning focus to your text editor following inverse search on macOS.

### Returning focus to Neovim after inverse search on macOS
**Relevant editor:** Neovim used with Skim or Zathura on macOS

From my testing (on macOS 12.1) Neovim failed to regain focus after inverse search from both Skim and Zathura.
Here is how to fix this problem (some steps are similar to refocusing solutions on Linux, so please excuse the repetition):

- Identify the name of your terminal (e.g. `iTerm`, `Alacritty`, `Terminal`, etc.);
  this is just the name of the macOS application for your terminal.
  Then define the following Vimscript function in `ftplugin/tex.vim`:
  ```vim
  function! s:TexFocusVim() abort
    " Replace `TERMINAL` with the name of your terminal application
    " Example: execute "!open -a iTerm"  
    " Example: execute "!open -a Alacritty"
    silent execute "!open -a TERMINAL"
    redraw!
  endfunction
  ```
  where you should replace `TERMINAL` with the name of your terminal application.
  The above code snippet runs the macOS `open` utility with the `-a` flag, which specifies an application, to refocus to your terminal, then redraws Vim's screen.
  Using `silent execute` instead of just `execute` suppresses `Press ENTER or type command to continue` messages, although you may want to start with just `execute` for debugging purposes.

- Then define the following Vimscript autocommand group in your `ftplugin/tex.vim`:
  ```vim
  augroup vimtex_event_focus
    au!
    au User VimtexEventViewReverse call s:TexFocusVim()
  augroup END
  ```
  The event `VimtexEventViewReverse`, conveniently provided by VimTeX, triggers whenever `VimtexInverseSearch` completes.
  The above autocommand runs the above-defined refocus function `s:TexFocusVim()` after every execution of inverse search.
  See `:help VimtexEventViewReverse` for documentation if interested.

### Returning focus to MacVim after inverse search on macOS
**Relevant editor:** MacVim used with Zathura on macOS

From my testing (on macOS 12.1) Neovim failed to regain focus after inverse search from Zathura (but *did* regain inverse search from Skim).
Here is how to fix the problem (the steps are similar to those for Neovim just above, so please excuse any repetition):

- Identify the name of your terminal (e.g. `iTerm`, `Alacritty`, `Terminal`, etc.);
  this is name of the macOS application for your terminal.
  Then define the following Vimscript function in `ftplugin/tex.vim`:
  ```vim
  function! s:TexFocusVim() abort
    if has("gui_running")  " for MacVim
      silent execute "!open -a MacVim"
    else                   " for terminal Vim
      " Replace `TERMINAL` with the name of your terminal application
      " Example: execute "!open -a iTerm"  
      " Example: execute "!open -a Alacritty"
      silent execute "!open -a TERMINAL"
    endif
    redraw!
  endfunction
  ```
  This code snippet uses macOS's `open` utility to refocus MacVim if you are running MacVim and your terminal application if you are running terminal Vim (just in case you happen to get inverse search working with terminal Vim on macOS).

  **Important:** you must have MacVim installed as a macOS application for `open -a MacVim` to work.
  If you installed MacVim with `brew install macvim` (instead of `brew install --cask macvim`) it is quite possible that you have a version MacVim for which `open -a MacVim` will not work.
  Here is what to do:
  - If you don't yet have MacVim on your system, run `brew install --cask macvim` (using `--cask` installs packages as a macOS application), and you'll be good to go.
  - If you already have MacVim installed, try running `open -a MacVim` from the command line.
    If this opens MacVim, you're good to go---you probably either downloaded MacVim from the MacVim website or used `brew install --cask macvim` originally.
  - If you have MacVim installed and `open -a MacVim` fails when run from the command line, you'll have to uninstall your MacVim and reinstall a macOS application version.
    If you installed your current MacVim with Homebrew, you can use the following three commands to uninstall and reinstall a correct MacVim (if you used some other installation method, you're on your own for this uninstalling step).
    ```sh
    brew unlink macvim          # remove symlinks to your current MacVim
    brew uninstall macvim       # uninstall your current MacVim
    ```
    Then reinstall MacVim as a macOS application (i.e. as a Homebrew cask):
    ```sh
    brew install --cask macvim  # install a macOS application version of MacVim
    ```
  After this, `open -a MacVim` should work correctly, and you can continue with the post-inverse-search refocus solution.

- Finally, define the following Vimscript autocommand group in your `ftplugin/tex.vim`:
  ```vim
  augroup vimtex_event_focus
    au!
    au User VimtexEventViewReverse call s:TexFocusVim()
  augroup END
  ```
  This autocommand runs the above-defined refocus function `s:TexFocusVim()` after every execution of inverse search using VimTeX's `VimtexEventViewReverse` event, which fires whenever `VimtexInverseSearch` completes.
  See `:help VimtexEventViewReverse` for documentation.

## Further reading
I suggest you read through the VimTeX documentation beginning at `:help g:vimtex_view_enabled` and ending at `:help g:vimtex_view_zathura_check_libsynctex`.
Although not all of the material will be relevant to your operating system or PDF reader, you will still find plenty of interesting information and configuration options.
Here is an example: VimTeX automatically opens your PDF reader when you first compile a document, even if you have not called `:VimtexView`.
If you prefer to disable this behavior, place the following code in your `ftplugin/tex.vim`:
```vim
" Don't automatically open PDF viewer after first compilation
let g:vimtex_view_automatic = 0
```

## Footnotes
