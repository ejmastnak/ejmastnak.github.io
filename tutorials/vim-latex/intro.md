---
title: Setting Up Vim for Efficiently Writing LaTeX
---
# Setting Up Vim for Efficiently Writing LaTeX

This series aims to make it easier for new users to set up the Vim or Neovim text editors for efficiently writing LaTeX documents. It is intended for anyone who...

- wants to switch from a different LaTeX editor to Vim, and is unsure how to proceed,
- wants a more pleasant and efficient experience writing LaTeX,
- is interested in taking real-time lecture notes using LaTeX, à la [Gilles Castel](https://castel.dev/),
- wants to manually configure compilation and PDF viewing without relying on third-party LaTeX plugins like [`vimtex`](https://github.com/vim-latex/vim-latex) or [`vim-latex`](https://github.com/vim-latex/vim-latex) (although [`vimtex`](https://github.com/vim-latex/vim-latex) is an excellent plugin and is covered in this series), or
- just wants to browse someone else's config and workflow out of curiosity.

### This series walks you through...
1. [**Vimscript best practices** for filetype-specific workflows]({% link tutorials/vim-latex/vimscript.md %}): how Vim's `ftplugin` system works; how to write and call Vimscript functions; how to set Vim key maps and call Vimscript functions with convenient keyboard shortcuts.

1. [**Compiling** LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %}): Vimscript functions and shell scripts for compiling `tex` files from within Vim; asynchronous compilation; mapping compilation functionality to convenient keyboard shortcuts; an introduction to the preconfigured compilation functions provided by [the `vimtex` plugin](https://github.com/lervag/vimtex).

1. [Integrating a **PDF reader** and Vim]({% link tutorials/vim-latex/pdf-reader.md %}): configuring forward and inverse search on a PDF viewer on macOS and Linux.

1. [**Snippets**, the key to real-time LaTeX]({% link tutorials/vim-latex/ultisnips.md %}): how to use [the `UltiSnips` plugin](https://github.com/SirVer/ultisnips) for writing snippets; suggestions for efficient snippet triggers; example snippets

### Show me results!

<!-- Show e.g. a GIF example with editor and PDF both on screen with real-time compilation going. Show my collection of lecture notes. -->


### For whom this series is written
This series is written with the voice, format, notation, and explanation style I would have liked to have access to if I were once again an inexperienced undergraduate learning the material for the first time myself.

All of the small discoveries I inefficiently scraped together from online tutorials, YouTube, Stack Overflow, Reddit and forums are compiled here in one place and (hopefully) synthesized into a self-contained work. References to official documentation are provided for any material deemed beyond the scope of this series.

**Assumptions**
- You know what LaTeX is, have a working installation, and know how to use it, at least for creating basic documents.
- You know what Vim is, have a working installation, and know how to use it, at least for basic text editing (e.g. at the level of `vimtutor`). If you use Neovim, I assume you can navigate small differences between Neovim and Vim, say Neovim's `init.vim` file replacing Vim's `vimrc` or the user's Neovim files living at `~/.config/nvim` as opposed Vim's `~/.vim`.
- You have installed Vim plugins before; you have a preferred plugin installation method (for example [`vim-plug`](https://github.com/junegunn/vim-plug), [`packer`](https://github.com/wbthomason/packer.nvim), Vim 8+/Neovim's built-in plugin system, etc...) and you know how to use it.
- You are comfortable with the idea of calling simple command line programs from a terminal emulator, for example using `pdflatex myfile.tex` to compile the LaTeX file `myfile.tex`.
- You have a working Python 3+ installation and are able to use `pip/pip3` to install Python packages.
- You are working on macOS or Linux (although many ideas here should be useful on Windows as well).

- Common abbreviations/macros for files like `.` for CWD, `..` for one directory up, `~` for the home directory


### References
The seminal work on the subject of Vim and LaTeX, and the original inspiration for this series, is Gilles Castel's [*How I'm able to take notes in mathematics lectures using LaTeX and Vim*](https://castel.dev/post/lecture-notes-1/). Anyone interested in combining LaTeX and Vim should read it.

[Video series](https://www.youtube.com/channel/UCOi2wszcfvs0j9Pcom3z9VA/featured)
