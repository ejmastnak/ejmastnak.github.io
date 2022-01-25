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

This series is written with the voice, format, notation, and explanation style I would have liked to have had access to if I were once again an inexperienced undergraduate learning the material for the first time myself. All of the small discoveries I inefficiently scraped together from online tutorials, YouTube, Stack Overflow, Reddit and other online forums are compiled here in one place and (hopefully) synthesized into a self-contained work. References to official documentation are provided for any material deemed beyond the scope of this series.

### This series walks you through...
0. Suggested [**prerequisites**]({% link tutorials/vim-latex/prerequisites.md %}) for getting the most out of this series, along with references that should get you up to speed if needed.
   Most readers can probably skip this, and jump directly to...

1. [**Snippets**, the key to real-time LaTeX]({% link tutorials/vim-latex/ultisnips.md %}): how to use the [`UltiSnips`](https://github.com/SirVer/ultisnips) plugin for writing snippets; suggestions for efficient snippet triggers; example snippets.

1. [Getting started with the **`vimtex` plugin**]({% link tutorials/vim-latex/vimtex.md %}):

1. [**Compiling** LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %}): Vimscript functions and shell scripts for compiling LaTeX files from within Vim; asynchronous compilation; mapping compilation functionality to convenient keyboard shortcuts; an introduction to the preconfigured compilation functionality provided by [the `vimtex` plugin](https://github.com/lervag/vimtex).

1. [Integrating a **PDF reader** and Vim]({% link tutorials/vim-latex/pdf-reader.md %}): configuring forward and inverse search on a PDF viewer on macOS and Linux.

1. [**Vimscript best practices** for filetype-specific workflows]({% link tutorials/vim-latex/vimscript.md %}): how Vim's `ftplugin` system works; how to write and call Vimscript functions; how to set Vim key maps and call Vimscript functions with convenient keyboard shortcuts.


Note: The seminal work on the subject of Vim and LaTeX, and my inspiration for attempting and ultimately succeeding in writing real-time LaTeX using Vim, is Gilles Castel's [*How I'm able to take notes in mathematics lectures using LaTeX and Vim*](https://castel.dev/post/lecture-notes-1/). You've probably seen it on the Internet if you dabble in Vim or LaTeX circles, and anyone interested in combining LaTeX and Vim should read it.

Since Castel's article leaves out a few technical details of implementation---things like writing Vimscript functions and key mappings, Vim's `ftplugin` system, how LaTeX compilation works, how to set up a PDF reader with forward and inverse search using Vim's client-server model, and so on---I decided to write a series more approachable to beginners that attempts to explain every step of the configuration process.

#### (Suggested) prerequisites
I wrote this series with beginners in mind, but some prerequisite knowledge is unavoidable.
To get the most out of this series, you should be comfortable with the material in the [**prerequisites** article]({% link tutorials/vim-latex/prerequisites.md %}), which offers external references or brief explanations to get you up to speed with all suggested prerequisites.
