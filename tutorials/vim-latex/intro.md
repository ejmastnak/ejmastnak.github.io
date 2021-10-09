---
title: Setting Up Vim for Efficiently Writing LaTeX
---
# Setting Up Vim for Efficiently Writing LaTeX

Hi what is the point?

The point is real-time LaTeX in lecture notes.

Show e.g. a GIF example with editor and PDF both on screen with real-time compilation going. Show my collection of lecture notes.

The point is to provide an end-to-end guide removing, to a reasonable extent, the considerable barrier to entry.

## Articles in this series
1. [**Vimscript best practices** for filetype-specific workflows]({% link tutorials/vim-latex/vimscript.md %}): how Vim's `ftplugin` system works; how to write functions and set keybindings in Vimscript

1. [**Compiling** LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %}): Vimscript functions and shell scripts for compiling `tex` files with convenient keyboard shortcuts from within Vim; the preconfigured compilation setup provided by the `vimtex` plugin.

1. [Integrating a **PDF reader** and Vim]({% link tutorials/vim-latex/pdf-reader.md %}): configuring forward and inverse search on a PDF viewer on macOS and Linux.

1. [**Snippets**: the key to real-time LaTeX]({% link tutorials/vim-latex/ultisnips.md %}): understand how to use the UltiSnips plugin for writing snippets; suggestions for efficient snippet triggers; example snippets


`setlocal` instead of `set` is best practice for buffer-local modifications like in `ftplugin`.

**Assumptions**
- You know what Vim is and know how to use it.
- You have installed Vim plugins before, and have a preferred method of your choice that you know how to use
- You are able to use `pip/pip3` to install Python plugins

## References
The seminal work on the subject of Vim and LaTeX, and the inspiration for this series, is Gilles Castel's [*How I'm able to take notes in mathematics lectures using LaTeX and Vim*](https://castel.dev/post/lecture-notes-1/). Consider this required reading if you are interested in combining LaTeX and Vim.
