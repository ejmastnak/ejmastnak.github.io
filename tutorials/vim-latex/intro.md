---
title: Setting Up Vim for Efficiently Writing LaTeX
---
# Setting Up Vim for Efficiently Writing LaTeX

This series aims to make it easier for new users to set up the Vim or Neovim text editors for efficiently writing LaTeX documents. It is intended for anyone who...

- wants to switch from a different LaTeX editor to Vim, and is unsure how to proceed,
- wants a more pleasant and efficient experience writing LaTeX,
- is interested in taking real-time lecture notes using LaTeX, à la [Gilles Castel](https://castel.dev/),
- wants to manually configure compilation and PDF viewing without relying on third-party LaTeX plugins like [`vimtex`](https://github.com/vim-latex/vim-latex) or [`vim-latex`](https://github.com/vim-latex/vim-latex) (although [`vimtex`](https://github.com/vim-latex/vim-latex) is an excellent plugin and I recommend its use in this series), or
- just wants to browse someone else's config and workflow out of curiosity.

Note: The seminal work on the subject of Vim and LaTeX, and my inspiration for attempting and ultimately succeeding in writing real-time LaTeX using Vim, is Gilles Castel's [*How I'm able to take notes in mathematics lectures using LaTeX and Vim*](https://castel.dev/post/lecture-notes-1/). You've probably seen it on the Internet if you dabble in Vim or LaTeX circles, and anyone interested in combining LaTeX and Vim should read it.

Since Castel's article leaves out a few technical details of implementation---things like writing Vimscript functions and key mappings, Vim's `ftplugin` system, how LaTeX compilation works, how to set up a PDF reader with forward and inverse search using Vim's client-server model, and so on---I decided to write a series more approachable to beginners that attempts to explain every step of the configuration process.

### This series walks you through...
1. [**Vimscript best practices** for filetype-specific workflows]({% link tutorials/vim-latex/vimscript.md %}): how Vim's `ftplugin` system works; how to write and call Vimscript functions; how to set Vim key maps and call Vimscript functions with convenient keyboard shortcuts.

1. [**Compiling** LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %}): Vimscript functions and shell scripts for compiling `tex` files from within Vim; asynchronous compilation; mapping compilation functionality to convenient keyboard shortcuts; an introduction to the preconfigured compilation functions provided by [the `vimtex` plugin](https://github.com/lervag/vimtex).

1. [Integrating a **PDF reader** and Vim]({% link tutorials/vim-latex/pdf-reader.md %}): configuring forward and inverse search on a PDF viewer on macOS and Linux.

1. [**Snippets**, the key to real-time LaTeX]({% link tutorials/vim-latex/ultisnips.md %}): how to use [the `UltiSnips` plugin](https://github.com/SirVer/ultisnips) for writing snippets; suggestions for efficient snippet triggers; example snippets


### For whom this series is written
This series is written with the voice, format, notation, and explanation style I would have liked to have had access to if I were once again an inexperienced undergraduate learning the material for the first time myself. All of the small discoveries I inefficiently scraped together from online tutorials, YouTube, Stack Overflow, Reddit and other online forums are compiled here in one place and (hopefully) synthesized into a self-contained work. References to official documentation are provided for any material deemed beyond the scope of this series.

#### (Suggested) prequisites
I wrote this series with beginners in mind, but some prequisite knowledge is unavoidable.  To successfully follow this series, you should probably meet the following criteria:

- You know what LaTeX is, have a working installation, and know how to use it, at least for creating basic documents.
- You know what Vim is, have a working installation, and know how to use it, at least for basic text editing (e.g. at the level of `vimtutor`). 
- If you use Neovim, I assume you can navigate the small differences between Neovim and Vim, say Neovim's `init.vim` file replacing Vim's `vimrc` or the user's Neovim files living at `~/.config/nvim` as opposed Vim's `~/.vim`. (Nontrivial differences between Neovim and Vim, such as the RPC protocol and client-server model, are explained separately for both editors.)
- You have installed Vim plugins before. You have a preferred plugin installation method (for example Vim 8+/Neovim's built-in plugin system, [`vim-plug`](https://github.com/junegunn/vim-plug), [`packer`](https://github.com/wbthomason/packer.nvim), etc...) and know what to do if told to install a Vim plugin.
- You have a working Python 3+ installation and are able to use `pip/pip3` to install Python packages.
- You are comfortable with the concept of calling simple command line programs from a terminal emulator, for example using `pdflatex myfile.tex` to compile the LaTeX file `myfile.tex`, `python3 myscript.py` to run a Python script, or even something as simple as `echo "Hello world!"` to write text to standard output.
  
- You are familiar with common abbreviations and macros used in shell scripting, such as `.` for the current working directory, `..` for one directory up, `~` for the home directory, and the `*` wildcard character used in [glob patterns](https://en.wikipedia.org/wiki/Glob_(programming)). 

- You are working on macOS or Linux. Although many ideas here should be useful on Windows, I have no meaningful experience with Windows and cannot offer any specific advice.

<!-- - Common 


<!-- [Video series](https://www.youtube.com/channel/UCOi2wszcfvs0j9Pcom3z9VA/featured) -->
