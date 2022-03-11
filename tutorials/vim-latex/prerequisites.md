---
title: Prerequisites for Writing LaTeX in Vim
---
# Suggested Prerequisites for Writing LaTeX in Vim

## About the series
This is part one in a [six-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents.
This article covers the prerequisites you should probably meet to get the most out of this series.
These prerequisites are listed below; each includes a suggestion or mini-tutorial for getting up to speed.

### Contents of this article
<!-- vim-markdown-toc GFM -->

* [Operating system](#operating-system)
* [LaTeX knowledge](#latex-knowledge)
* [Vim knowledge](#vim-knowledge)
* [Neovim literacy](#neovim-literacy)
* [Vim plugins](#vim-plugins)
* [Navigating the Vim help](#navigating-the-vim-help)
* [Python 3 installation](#python-3-installation)
* [Command line usage](#command-line-usage)
* [Shell scripting lingo](#shell-scripting-lingo)

<!-- vim-markdown-toc -->

### Operating system
- Prerequisite: you are working on macOS, Linux, or some other Unix variant.

- Suggestion: If you use Windows, I suggest you follow along with the series as is;
  most techniques and ideas should work fine, and if XYZ doesn't work as expected, search the Internet for "how to use XYZ Vim/LaTeX/shell feature on Windows".
  I have no meaningful experience with Windows and cannot offer any specific advice, but there should be plenty of Windows users on the Internet more knowledgeable than I am who have figured out a solution or workaround.

### LaTeX knowledge
- Prerequisite: you know what LaTeX is, have a working distribution of LaTeX installed locally on your computer, and know how to use it, at least for creating basic documents.
  Among other things, this means you should have the `pdflatex` and `latexmk` programs installed on your system and available from a command line.

- Suggestions:
  - See the [LaTeX project's official installation instructions](https://www.latex-project.org/get/) for installing LaTeX on various operating systems.

  - I recommend the [tutorial at learnlatex.org](https://www.learnlatex.org/en/) as a starting point for learning LaTeX.
    Another decent option, despite the clickbait title, is [Overleaf's *Learn LaTeX in 30 minutes*](https://www.overleaf.com/learn/latex/Learn_LaTeX_in_30_minutes).
    Note that you can find hundreds of other LaTeX guides on the Web, but this can be just as overwhelming as it is helpful.
  Be wary of poorly written or non-comprehensive tutorials, of which there are unfortunately plenty.
  The [LaTeX project's list of helpful links](https://www.latex-project.org/help/links/) is a good place to find high-quality documentation and tutorials.

  
### Vim knowledge
- Prerequisite: you know what Vim is, have a working local installation of Vim or Neovim on your computer, and know how to use it, at least for basic text editing (for example at the level of `vimtutor`).
  At the risk of belaboring the obvious, this means you must have either the `vim` or `nvim` programs installed and available on a command line.
  
  Suggestions:
  - Installation: Vim should come installed on most of the Unix-based systems this series is written for.
    But, just in case, here are the [official instructions for installing Vim](https://github.com/vim/vim#installation).
  - And for Neovim: [official instructions for installing Neovim](https://github.com/neovim/neovim/wiki/Installing-Neovim).
    If you are choosing between Vim and Neovim specifically for the purpose of this series, I encourage you to choose Neovim---forward and inverse search (i.e. making your text editor communicate with a PDF reader) will be easier to set up.

  - To get started with Vim, try the interactive Vim tutorial (usually called the *Vim tutor*) that ships with Vim.
  You access the Vim tutor differently depending on your choice of Vim and Neovim.
    - If you have Vim installed: open a terminal emulator and enter `vimtutor`.
    - If you have Neovim installed: open Neovim by typing `nvim` in a terminal.
      Then, from inside Neovim, type `:Tutor` and press the Enter key.

    There is also a well-regarded third-party interactive Vim tutor available at [www.openvim.com/tutorial.html](https://www.openvim.com/tutorial.html).

    After (or in place of) the Vim tutor, consider reading through [Learn Vim the Smart Way](https://github.com/iggredible/Learn-Vim).

### Neovim literacy
- Prerequisite: if you use Neovim, you should know how to navigate the small differences between Neovim and Vim, for example Neovim's `init.vim` file replacing Vim's `vimrc` or the user's Neovim configuration files living at `~/.config/nvim` as opposed Vim's `~/.vim`.
  <!-- (Nontrivial differences between Neovim and Vim, such as the RPC protocol and client-server model, are explained separately for both editors.) -->

- Suggestion: read through Neovim's `:help vim-differences`.

### Vim plugins
- Prerequisite: you have installed Vim plugins before,
  have a preferred plugin installation method (e.g. Vim 8+/Neovim's built-in plugin system, [`vim-plug`](https://github.com/junegunn/vim-plug), [`packer`](https://github.com/wbthomason/packer.nvim), etc...),
  and will know what to do when told to install a Vim plugin.

  Suggestions:
  - If you want an external program to manage your plugins for you, use the well-regarded `vim-plug` plugin.
  The [`vim-plug` GitHub page](https://github.com/junegunn/vim-plug) contains everything you need to get started.
  - If you prefer to manage your plugins manually, use Vim/Neovim's built-in plugin management system.
  The relevant documentation lives at `:help packages` but is unnecessarily complicated for a beginner's purposes.
  When getting started with the built-in plugin system, it is enough to perform the following:
  1. Create the folder `pack` inside your root Vim configuration folder (i.e. create `~/.vim/pack/` if using Vim and `~/.config/nvim/pack/` if using Neovim)
  1. Inside `pack/`, create an arbitrary number of directories used to organize your plugins by category (e.g. create `pack/global/`, `pack/file-specific/`, etc...).
     These names can be anything you like and give you the freedom to organize your plugins as you see fit.
     *You probably just want to start with one plugin directory*, e.g. `pack/plugins/`, and create more if needed as you plugin collection grows.
  1. Inside each of the just-created organizational directories, create a directory named `start/` (you will end up with e.g. `pack/plugins/start/`)
  1. Clone a plugin repository from GitHub into a `start/` directory.
     
  Since that might sound abstract, an example interactive shell session used to install the [`vimtex`](https://github.com/lervag/vimtex), [`ultisnips`](https://github.com/SirVer/ultisnips), and [`vim-dispatch`](https://github.com/tpope/vim-dispatch) plugins (all used later in this series) using Vim/Neovim's built-in plugin system would look like this:
   ```sh
   # Change directories to the root Vim config directory
   cd ~/.vim         # for Vim
   cd ~/.config/nvim  # for Neovim

   # Create the required package directory structure
   mkdir -p pack/plugins/start
   cd pack/plugins/start

   # Clone the plugins' GitHub repos from inside `start/`
   git clone https://github.com/lervag/vimtex
   git clone https://github.com/SirVer/ultisnips
   git clone https://github.com/tpope/vim-dispatch
   ```
   For orientation, the resulting file structure would be:
   ```sh
   ~/.vim/
   └── pack/
       └── plugins/
           └── start/
               ├── vimtex/
               ├── ultisnips/
               └── vim-dispatch/
   ```
   The `vimtex`, `ultisnips`, and `vim-dispatch` plugins would then automatically load whenever Vim starts up.

  If you install a plugin manually, its documentation will not be automatically available with Vim's `:help` command.
  To generate the plugin documentation, first ensure the plugin has a `doc` directory, which is where documentation should be stored.
  If a plugin `doc` directory exists, you can generate its documentation with the Vim command
  ```vim
  :helptags /path/to/plugin/doc
  ```
  You can also use `:helptags ALL` to generate documentation for all plugins with a `doc` directory;
  see See `:help helptags` for background.

### Navigating the Vim help
You should be comfortable using Vim/Neovim's built in documentation, which you access with the `:help` command.
The Vim documentation is hyperlinked, and if you have syntax highlighting enabled, clickable hyperlinks to difference help chapters and sections should be clearly highlighted.
- Press `<Ctrl>]` with your cursor over a highlighted documentation section to jump to that section
- Press `<Ctrl>o` to jump backward through your navigation history (e.g. to return to your original position before pressing `<Ctrl>]`)
- Read `:help 01.1`, which explains the basics of the Vim documentation
- Read `:help notation` to understand the notation used in the Vim documentation

### Python 3 installation
- Prerequisite: you have a working Python 3+ installation and are able to use `pip/pip3` to install Python packages.

- Suggestion: refer to one of the many guides on the Internet for setting up a Python 3 installation for your operating system.
  You should end up with the `python`/`python3` and `pip`/`pip3` commands available from a command line.

### Command line usage
- Prerequisite: You are comfortable with the concept of calling simple command line programs from a terminal emulator, for example using `pdflatex myfile.tex` to compile the LaTeX file `myfile.tex`, using `python3 myscript.py` to run a Python script, or even something as simple as `echo "Hello world!"` to write text to standard output.
<!-- I assume anyone interested in Vim --> 
  
- Suggestion: I assume someone interested in using a command line editor like Vim is already familiar with the command line.
  But in case you need practice, search YouTube for one of the many guides on getting started with the command line.
  
### Shell scripting lingo
- Prerequisite: You are familiar with the more common abbreviations and macros used in shell scripting.

- There are so few things to know I can just show you.
  The abbreviations should know for this series are:
  - `.` is shorthand for the current working directory
  - `..` is shorthand for one directory above the current working directory
  - `~` is shorthand for the home directory
  - `*` is the match-all wildcard character used in [glob patterns](https://en.wikipedia.org/wiki/Glob_(programming)).
