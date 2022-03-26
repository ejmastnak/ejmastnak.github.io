---
title: Real-time LaTeX Using Vim and Neovim

carousels:
  - images: 
    - image: /assets/images/vim-latex/screenshots/ss.png
    - image: /assets/images/vim-latex/screenshots/cm.png
    - image: /assets/images/vim-latex/screenshots/optics.png
    - image: /assets/images/vim-latex/screenshots/fizmer.png
    - image: /assets/images/vim-latex/screenshots/qm.png
---
# Real-time LaTeX Using Vim and Neovim

This tutorial series aims to make it easier for new users to set up the Vim or Neovim text editors for efficiently writing LaTeX documents.
It is intended for anyone who...

- is interested in taking real-time lecture notes using LaTeX, à la [Gilles Castel](https://castel.dev/),
- just wants a more pleasant and efficient LaTeX experience, whether this is at real-time university lecture speed or not,
- hopes to switch to Vim from a different LaTeX editor, but is unsure how to proceed, or
- just wants to browse someone else's workflow and configuration out of curiosity.

### This series walks you through...
1. Suggested [**prerequisites**]({% link tutorials/vim-latex/prerequisites.md %}) for getting the most out of the series, along with references that should get you up to speed if needed.

1. [**Snippets**, the key to real-time LaTeX]({% link tutorials/vim-latex/ultisnips.md %}): how to use the [UltiSnips](https://github.com/SirVer/ultisnips) plugin for writing snippets; suggestions for efficient snippet triggers; example snippets.

1. Vim's [**filetype plugin system**]({% link tutorials/vim-latex/ftplugin.md %}): understanding how Vim lets you create customizations that apply only to the LaTeX filetype, which will help you understand the VimTeX plugin.

1. [Getting started with **the VimTeX plugin**]({% link tutorials/vim-latex/vimtex.md %}): navigating the VimTeX documentation;
   LaTeX-specific text objects;
   an overview of VimTeX's default key mappings and how to customize them if desired;
   customizing VimTeX's default settings, and more.

1. [**Compiling** LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %}): setting up the compilation interface provided by [the VimTeX plugin](https://github.com/lervag/vimtex);
   an explanation of how to use the `pdflatex` and `latexmk` programs and manually create an asynchronous LaTeX compiler plugin for those who want to.

1. [Integrating a **PDF reader** and Vim]({% link tutorials/vim-latex/pdf-reader.md %}): suggestions for a PDF reader on both Linux and macOS; detailed instructions for configuring forward and inverse search on both operating systems; troubleshooting window focus problems.

1. [**A Vimscript primer**]({% link tutorials/vim-latex/vimscript.md %}) explaining the key mappings and Vimscript functions used in this tutorial.

#### Written with beginners in mind
The series is written with the voice, format, notation, and explanation style I would have liked to have read if I were once again an inexperienced undergraduate learning the material for the first time myself.
All of the small discoveries I inefficiently scraped together from official documentation, online tutorials, YouTube, Stack Overflow, Reddit, and other online forums are compiled here and (hopefully) synthesized into an easily-followed, self-contained work.
References to official documentation are provided for any material deemed beyond the scope of the series.

#### Evidence this system works
As evidence that the techniques and setup in this tutorial work, here are [1500+ pages of typeset physics notes](https://ejmastnak.github.io/fmf.html) from my undergraduate studies, most of them written during university lecture in real time (although grammar and style were improved after).
Here are some examples of what these notes look like:

{% include carousel.html height="108.1" unit="%" duration="600" number="1" %}

#### (Suggested) prerequisites
I wrote this series with beginners in mind, but some prerequisite knowledge is unavoidable.
To get the most out of this series, you should be comfortable with the material in the [prerequisites article]({% link tutorials/vim-latex/prerequisites.md %}), which offers external references or brief explanations to get you up to speed with all suggested prerequisites.

#### The original Vim-LaTeX article
The seminal work on the subject of Vim and LaTeX, and my inspiration for attempting and ultimately succeeding in writing real-time LaTeX using Vim, is Gilles Castel's [*How I'm able to take notes in mathematics lectures using LaTeX and Vim*](https://castel.dev/post/lecture-notes-1/).
You've probably seen it on the Internet if you dabble in Vim or LaTeX circles, and you should definitely read it if you haven't yet.
This series builds on Castel's article by more thoroughly walking the reader through technical details of implementation (e.g. the details of setting up a PDF reader with forward and inverse search using Vim's client-server model, how to write Vimscript functions and key mappings, how Vim's `ftplugin` system works, how to manually compile LaTeX documents, and so on).

#### Config
Since someone will probably be curious, here is an overview of the setup used in this series:
- Editor: [Neovim](https://neovim.io/)
- Terminal: [Alacritty](https://alacritty.org/)
- Colorscheme: [Nord](https://www.nordtheme.com/)
- Font: [Source Code Pro](https://github.com/adobe-fonts/source-code-pro) in screenshots and GIFs and [Computer Modern](https://www.tug.org/FontCatalogue/computermodern/) on this website; at the time of writing, the fonts used on this website are available on [this demo page](https://www.checkmyworking.com/cm-web-fonts/).
- OS: [Arch Linux](https://archlinux.org/) as a daily driver; [macOS](https://www.apple.com/macos/) for testing cross-platform functionality
- Window manager: [i3](https://i3wm.org/) on Linux; [Amethyst](https://ianyh.com/amethyst/) on macOS
- GIF recording and screen capture: [Menyoki](https://github.com/orhun/menyoki)
- Dotfiles: [github.com/ejmastnak/dotfiles](https://github.com/ejmastnak/dotfiles), where you can find both my main [Neovim config](https://github.com/ejmastnak/dotfiles/tree/main/config/nvim) and a smaller [Vim config](https://github.com/ejmastnak/dotfiles/tree/main/config/nvim) for testing Vim-specific inverse search features for this series.

<p style="text-align: center"><a href="/tutorials/vim-latex/prerequisites.html"><strong><em>Click to get started!</em></strong></a></p>
