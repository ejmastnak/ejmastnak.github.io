---
title: Setting Up Vim for Efficiently Writing LaTeX
---
# Setting Up Vim for Efficiently Writing LaTeX

This series aims to make it easier for new users to set up the Vim, Neovim, gVim, or MacVim text editors for efficiently writing LaTeX documents.
It is intended for anyone who...

<!-- - is interested in switching from a different LaTeX editor to Vim, and is unsure how to proceed, -->
- wants a more pleasant and efficient experience writing LaTeX,
- is interested in taking real-time lecture notes using LaTeX, à la [Gilles Castel](https://castel.dev/),
- just wants to browse someone else's workflow and configuration out of curiosity.

As proof that the concepts in this tutorial work, here are [1500+ pages of typeset physics notes](https://ejmastnak.github.io/fmf.html) from my undergraduate studies, most of them written real-time during lecture (although grammar and style were improved after).

### This series walks you through...
1. Suggested [**prerequisites**]({% link tutorials/vim-latex/prerequisites.md %}) for getting the most out of this series, along with references that should get you up to speed if needed.
   Many readers can probably quickly skim through this and move to...

1. [**Snippets**, the key to real-time LaTeX]({% link tutorials/vim-latex/ultisnips.md %}): how to use the [UltiSnips](https://github.com/SirVer/ultisnips) plugin for writing snippets; suggestions for efficient snippet triggers; example snippets.

1. [Getting started with **the VimTeX plugin**]({% link tutorials/vim-latex/vimtex.md %}): navigating the VimTeX documentation; LaTeX-specific text objects; an overview of VimTeX's default key mappings and how to customize them if desired; practical manipulation and navigation of LaTeX source code using VimTeX's commands; customizing VimTeX's default settings, and more.

1. [**Compiling** LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %}): setting up the compilation interface provided by [the VimTeX plugin](https://github.com/lervag/vimtex); an explanation of how to use the `pdflatex` and `latexmk` programs manually; building an asynchronous Vim compiler plugin for LaTeX for those who want to.

1. [Integrating a **PDF reader** and Vim]({% link tutorials/vim-latex/pdf-reader.md %}): suggestions for a PDF reader on both Linux and macOS; detailed instructions for configuring forward and inverse search on both operating systems; troubleshooting window focus problems.

1. [**Vimscript best practices** for filetype-specific workflows]({% link tutorials/vim-latex/vimscript.md %}): how Vim's `ftplugin` system works; how to write and call Vimscript functions; how to set Vim key maps and call Vimscript functions with convenient keyboard shortcuts.

The series is written with the voice, format, notation, and explanation style I would have liked to have read if I were once again an inexperienced undergraduate learning the material for the first time myself.
All of the small discoveries I inefficiently scraped together from official documentation, online tutorials, YouTube, Stack Overflow, Reddit, and other online forums are compiled here and (hopefully) synthesized into a self-contained work.
References to official documentation are provided for any material deemed beyond the scope of this series.

#### (Suggested) prerequisites
I wrote this series with beginners in mind, but some prerequisite knowledge is unavoidable.
To get the most out of this series, you should be comfortable with the material in the [prerequisites article]({% link tutorials/vim-latex/prerequisites.md %}), which offers external references or brief explanations to get you up to speed with all suggested prerequisites.

#### The original Vim-LaTeX article
The seminal work on the subject of Vim and LaTeX, and my inspiration for attempting and ultimately succeeding in writing real-time LaTeX using Vim, is Gilles Castel's [*How I'm able to take notes in mathematics lectures using LaTeX and Vim*](https://castel.dev/post/lecture-notes-1/).
You've probably seen it on the Internet if you dabble in Vim or LaTeX circles, and you should definitely read it if you haven't yet.
This series builds on Castel's article by more thoroughly walking the reader through technical details of implementation (e.g. the details of setting up a PDF reader with forward and inverse search using Vim's client-server model, how to write Vimscript functions and key mappings, how Vim's `ftplugin` system works, how to manually compile LaTeX documents, and so on).
