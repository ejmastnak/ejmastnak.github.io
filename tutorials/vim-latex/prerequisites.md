---
title: Prerequisites for Writing LaTeX in Vim
---
# Suggested Prerequisites for Writing LaTeX in Vim

To use this series effectively, you should probably meet the prerequisites listed below; each includes a suggestion or mini-tutorial for getting up to speed.

### Operating system
- Prerequisite: You are working on macOS, Linux, or some other Unix variant.

- Suggestion: most techniques in the series should work on Windows, I just have no meaningful experience with Windows and cannot offer any specific advice.
  I suggest you follow along with the series as is, and, if XYZ doesn't work as expected, search the Internet for "how to use XYZ Vim/LaTeX/shell feature on Windows".
  There should be plenty of people more knowledgeable than I am who have figured out a solution or workaround.

### LaTeX knowledge
- Prerequisite: You know what LaTeX is, have a working installation, and know how to use it, at least for creating basic documents.

- Suggestions:
  - See the [LaTeX project's official installation instructions](https://www.latex-project.org/get/) for installing LaTeX.

  - I recommend the [tutorial at learnlatex.org](https://www.learnlatex.org/en/) as a starting point for learning LaTeX.
    Another decent option, despite the clickbait title, is [Overleaf's *Learn LaTeX in 30 minutes*](https://www.overleaf.com/learn/latex/Learn_LaTeX_in_30_minutes).
    Note that you can find hundreds of other LaTeX guides on the web, but this can be just as overwhelming as it is helpful.
  Be wary of poorly written or non-comprehensive tutorials, of which there are unfortunately plenty.
  The [LaTeX project's list of helpful links](https://www.latex-project.org/help/links/) is a good place to find high-quality documentation and tutorials.

  
### Vim knowledge
- Prerequisite: You know what Vim is, have a working installation, and know how to use it, at least for basic text editing (for example at the level of `vimtutor`). 
  
  Suggestions:
  - Installation: Vim should come installed on most of the Unix-based systems this series is written for.
    But just in case: [official instructions for installing Vim](https://github.com/vim/vim#installation).
  - And for Neovim: [official instructions for installing Neovim](https://github.com/neovim/neovim/wiki/Installing-Neovim).
    <!-- If you are choosing between Vim and Neovim specifically for the purposes of this series. -->

  - To get started with Vim, try the interactive Vim tutorial (usually called the *Vim tutor*) that ships with Vim.
  You access the Vim tutor differently depending on your choice of Vim and Neovim.
    - If you have Vim installed: open a terminal emulator and enter `vimtutor`.
    - If you have Neovim installed: open Neovim by typing `nvim` in a terminal. 
      Then, from inside Neovim, type `:Tutor` and press the Enter key.

    There is also a well-regarded third-party interactive Vim tutor available at [www.openvim.com/tutorial.html](https://www.openvim.com/tutorial.html).

    After (or in place of) the Vim tutor, consider [Learn Vim the Smart Way](https://github.com/iggredible/Learn-Vim).

### Neovim literacy
- Prerequisite: If you use Neovim, you can navigate the small differences between Neovim and Vim, say Neovim's `init.vim` file replacing Vim's `vimrc` or the user's Neovim configuration files living at `~/.config/nvim` as opposed Vim's `~/.vim`.
  <!-- (Nontrivial differences between Neovim and Vim, such as the RPC protocol and client-server model, are explained separately for both editors.) -->

- Suggestion: read through Neovim's `:help vim-differences`.

### Vim plugins
- Prerequisite: You have installed Vim plugins before.
  You have a preferred plugin installation method (for example Vim 8+/Neovim's built-in plugin system, [`vim-plug`](https://github.com/junegunn/vim-plug), [`packer`](https://github.com/wbthomason/packer.nvim), etc...) and will know what to do when told to install a Vim plugin.

  Suggestions:
  - If want to outsource you plugin management to an external program, use `vim-plug`.
  The [`vim-plug` GitHub page](https://github.com/junegunn/vim-plug) contains everything you need to get started.
  - If you prefer to manage your plugins yourself, use Vim/Neovim's built-in plugin management system.
  The relevant documentation lives at `:help packages` but is unnecessarily complicated for a beginner's purposes.
  When getting started, it is enough to perform the following three levels of directory creation:
  1. Create the folder `pack` inside your root Vim configuration folder (i.e. create `~/.vim/pack/` if using Vim and `~/.config/nvim/pack/` if using Neovim)
  1. Inside `pack/`, create an arbitrary number of directories used to organize your plugins by category (e.g. `pack/global/`, `pack/file-specific/`, etc...).
     These names can be anything you like and give you the freedom to organize your plugins as you see fit.
     You probably just want to start with one plugin directory, e.g. `pack/plugins/`, and create more if needed as you plugin collection grows.
  1. Inside each of the organizational directories inside `pack/`, create a directory named `start/` (you will end up with e.g. `pack/plugins/start/`)
  1. Clone a plugin repository from GitHub into a `start/` directory.
     An example file structure might read...
     ```sh
     ~/.vim/
     └── pack/
         └── plugins/
             └── start/
                 ├── vimtex/
                 ├── ultisnips/
                 └── vim-dispatch/
     ```
     The contents of the `vimtex`, `ultisnips`, and `vim-dispatch` directories would then be automatically loaded whenever Vim starts up.

### Python 3 installation
- You have a working Python 3+ installation and are able to use `pip/pip3` to install Python packages.

### Command line usage
- You are comfortable with the concept of calling simple command line programs from a terminal emulator, for example using `pdflatex myfile.tex` to compile the LaTeX file `myfile.tex`, `python3 myscript.py` to run a Python script, or even something as simple as `echo "Hello world!"` to write text to standard output.
  
  <!-- https://www.shellscript.sh/index.html -->
  
### Shell scripting lingo
- You are familiar with common abbreviations and macros used in shell scripting, such as `.` for the current working directory, `..` for one directory up, `~` for the home directory, and the `*` wildcard character used in [glob patterns](https://en.wikipedia.org/wiki/Glob_(programming)). 
