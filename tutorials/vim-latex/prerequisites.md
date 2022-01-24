---
title: Prerequisites for Writing LaTeX in Vim
---
# Suggested Prerequisites for Writing LaTeX in Vim

This pages explains some prerequisites and gives references or mini-explanations.

I wrote this series with beginners in mind, but some prequisite knowledge is unavoidable. To successfully follow this series, you should probably meet the following criteria:

- You know what LaTeX is, have a working installation, and know how to use it, at least for creating basic documents.
- You know what Vim is, have a working installation, and know how to use it, at least for basic text editing (e.g. at the level of `vimtutor`). 
- If you use Neovim, I assume you can navigate the small differences between Neovim and Vim, say Neovim's `init.vim` file replacing Vim's `vimrc` or the user's Neovim files living at `~/.config/nvim` as opposed Vim's `~/.vim`. (Nontrivial differences between Neovim and Vim, such as the RPC protocol and client-server model, are explained separately for both editors.)
- You have installed Vim plugins before. You have a preferred plugin installation method (for example Vim 8+/Neovim's built-in plugin system, [`vim-plug`](https://github.com/junegunn/vim-plug), [`packer`](https://github.com/wbthomason/packer.nvim), etc...) and know what to do if told to install a Vim plugin.
- You have a working Python 3+ installation and are able to use `pip/pip3` to install Python packages.
- You are comfortable with the concept of calling simple command line programs from a terminal emulator, for example using `pdflatex myfile.tex` to compile the LaTeX file `myfile.tex`, `python3 myscript.py` to run a Python script, or even something as simple as `echo "Hello world!"` to write text to standard output.
  
- You are familiar with common abbreviations and macros used in shell scripting, such as `.` for the current working directory, `..` for one directory up, `~` for the home directory, and the `*` wildcard character used in [glob patterns](https://en.wikipedia.org/wiki/Glob_(programming)). 

- You are working on macOS or Linux. Although many ideas here should be useful on Windows, I have no meaningful experience with Windows and cannot offer any specific advice.
