---
title: Compilation | Vim and LaTeX Part 1
---
# Compiling LaTeX Documents in a Vim-Based Workflow

## About the series
This is part two in a four-part series explaining how to use the Vim text editor to efficiently write LaTeX documents. This article covers compilation and should explain everything you need to get started compiling LaTeX documents from within Vim, either with customized scripts or using the `vimtex` plugin's compilation features.

Visit [the introduction]({% link tutorials/vim-latex/intro.md %}) for an overview of the series. Use the list below navigate to other parts in the series...
1. [Vimscript best practices for filetype-specific plugins]({% link tutorials/vim-latex/vimscript.md %})
1. [Compiling LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %})
1. [Integrating Vim and a PDF reader]({% link tutorials/vim-latex/pdf-reader.md %})
1. [Snippets: the key to real-time LaTeX]({% link tutorials/vim-latex/ultisnips.md %})


## Contents of this article
<!-- vim-markdown-toc Marked -->

* [Functionality implemented in this article](#functionality-implemented-in-this-article)
* [What options to use with `pdflatex` and `latexmk`](#what-options-to-use-with-`pdflatex`-and-`latexmk`)
  * [pdflatex](#pdflatex)
  * [latexmk](#latexmk)
  * [You can use other options, too...](#you-can-use-other-options,-too...)
* [Implementation: compilation scripts and Vim functions](#implementation:-compilation-scripts-and-vim-functions)
  * [Main shell script](#main-shell-script)
  * [Supporting Vimscript](#supporting-vimscript)
* [Implementation: error message parsing](#implementation:-error-message-parsing)
* [Implementation: detecting `minted` and using `--shell-escape`](#implementation:-detecting-`minted`-and-using-`--shell-escape`)
* [Implementation: toggling compilation with `latexmk`](#implementation:-toggling-compilation-with-`latexmk`)

<!-- vim-markdown-toc -->

## Functionality implemented in this article
This article covers the following:

- The `pdflatex` and `latexmk` commands and what options to use with each

- Vimscript functions for compiling the current `tex` source file using either `pdflatex` or `latexmk`, controlled from within Vim with a keyboard shortcut of your choice

- Compilation runs as an asynchronous background process, and focus stays in Vim throughout compilation (i.e. you don't have to wait until compilation finishes to be able to type.)

- Compilation error messages are displayed, with line number, in Vim's QuickFix menu, allowing you to jump directly to the error with Vim's `:cnext` command. Irrelevant log messages are filtered out using an approriate Vim `errorformat` string customized for LaTeX compilation.

And also some features of secondary importance:

- A toggle function for switching between `latexmk` and `pdflatex` compilation mapped to convenient keyboard shortcut of your choice.

- For `minted` package users: I occasionally use the `minted` package for including highlighted code blocks in my LaTeX documents. The `minted` package only works if the `tex` source file is compiled with the `--shell-escape` option enabled. Thus, this article shows how to implement:
  1. a script that parses a just-opened `tex` document for occurrences of the `minted` package and automatically enables compilation with `--shell-escape` if `minted` is detected.
  2. a toggle function for turning `--shell-escape` off or on, mapped to convenient keyboard shortcut of your choice.


## What options to use with `pdflatex` and `latexmk`
For our purposes, `pdflatex` and `latexmk` are two command-line programs that turn the LaTeX code in a `tex` source file into a PDF document. The `pdflatex` program ships by default with any standard LaTeX installation. Meanwhile, `latexmk` is a useful Perl script written by John Collins, used in practice to fully automate compiling complicated LaTeX documents with cross-references and bibliographies. The `latexmk` script actually calls `pdflatex` (or similar programs) under the hood, but automatically determines exactly how many `pdflatex` runs are needed to compile a document.

Online and GUI LaTeX editors, such as Overleaf, TeXShop or TeXStudio, also compile `tex` documents with `latexmk` or `pdflatex` (or similar command line programs) under the hood. You just don't see this directly because the `pdflatex` calls are hidden from immediate view behind a graphical interface.

To get anything beyond basic functionality from `pdflatex` and `latexmk`, you need to supplement that base commands with a few options. These options are covered below.

### pdflatex
The full `pdflatex` command I use to compile `tex` files, with all options shown, is
  ```
  pdflatex -file-line-error -halt-on-error -interaction=nonstopmode -output-dir={directory} -synctex=1 {sourcefile.tex}
  ```
  where `{sourcefile.tex}` and `directory` would be replaced by the actual names of the `tex` file you're compiling and the path to the directory where you want the output files to go. Here is an explanation of each option used above:
- `-file-line-error` prints error  messages in the form `file:line:error`. Here is an example of what `pdflatex` reports if I incorrectly leave out the `\item` command in an `itemize` environment on line 15 of the file `test.tex`:
  ```
  ././test.tex:15: LaTeX Error: Something's wrong--perhaps a missing \item.
  ```
  The format used by `-file-line-error` makes it easier to parse error messages using Vim's `errorformat` functionality, which is covered in more detail in **TODO**.

- `-halt-on-error` exits `pdflatex` immediately if an error is encountered during compilation (instead of attempting to continue compiling the document in spite of the error)

- `-interaction=nonstopmode` sets `pdflatex`'s run mode to not stop on errors. The idea is to use `-interaction=nonstopmode` *together* with `-halt-on-error`  to halt compilation at the first error and return control to the parent process/program from which `pdflatex` was run.

  If you're curious for official documentation of the other possible values of the `interaction` option: run `texdoc texbytopic` in a shell, which opens a PDF manual. Look for the chapter `Running TeX` (chapter 32 at the time of writing) and find the subsection `Run modes` (subsection 32.2 at the time of writing), where you will find TeX's run modes explained; the possible values of the `-interaction` option for `pdflatex` have the same effect.

- `-output-dir=directory` writes output files of compilation in the directory `directory` instead of the current working directory from which `pdflatex` was run. I set `directory` equal to the parent directory of the to-be-compiled `tex` file; e.g. to compile `dir1/dir2/myfile.tex` I would use `directory=dir1/dir2`

- `synctex=1` generates SyncTeX data for the compiled file, which enables inverse search between a PDF reader and the `tex` source file; more on this in [integrating a PDF reader and Vim]({% link tutorials/vim-latex/pdf-reader.md %}).

  Using `synctex=1` saves the `synctex` data in a `gz` archive with the extension `.synctex.gz`. Possible values of the `synctex` argument other than `1` are documented under `man synctex`

You can find full documentation of `pdflatex` options at `man pdflatex`.

### latexmk
When compiling `tex` files with `latexmk` instead of with `pdflatex`, I use the command
```
latexmk -pdf -output-directory={directory}
```
*together with the following* `latexmkrc` *file*:
```
$pdflatex = "pdflatex -file-line-error -halt-on-error -interaction=nonstopmode -synctex=1";
```
Regarding the options in the `latexmk` call:
- `-pdf` tells `latexmk` to compile using `pdflatex`, which creates a `pdf` output file.

- `-output-dir=directory` writes the files outputted by `latexmk` to the directory `directory` instead of to the current working directory from which `latexmk` was run. I set `directory` equal to the parent directory of the to-be-compiled `tex` file; e.g. I would use `directory=dir1/dir2` to compile `dir1/dir2/myfile.tex`.

The `latexmkrc` file configures `latexmk`'s default behaviour; the `$pdflatex = "..."` line in my `latexmkrc` specifies the options `latexmk` should use when using `pdflatex` for compilation. This alleviates from from having to write all that code by hand on every `latexmk` call. Note that these options match the options for the vanilla `pdflatex` calls described in the [**pdflatex**](#pdflatex) section. 


You should put your `latexmkrc` file at the location `~/.latexmkrc` or `XDG_CONFIG_HOME/latexmk/latexmkrc`, which exands to `~/.config/latexmk/latexmkrc` on most Unix systems. The `latexmkrc` file's usage is documented in `man latexmkrc` under the section `CONFIGURATION/INITIALIZATION (RC) FILES`. The `latexmk` program is well-documented in general; see`man latexmk` for far more information than is covered here, including the possibility of fancy features like continuous compilation.

### You can use other options, too...
The `pdflatex` and `latexmk` commands and options described above are by no means the best or only way to compile LaTeX documents. Consider them a starting point based on what has served me well during my undergraduate studies. I encourage you to read through the `pdflatex` and `latexmk` documentation and see what works for you.

## Implementation: compilation scripts and Vim functions
Since `pdflatex` and `latexmk` must be called from the command line, I manage most of my compilation with shell scripts. I then call these shell scripts with one-liner Vimscript functions.

Directory structure:
```
nvim
├── ...
├── ftplugin
│   ├── ...
│   └── tex
│       ├── errorformat.vim
│       ├── tex.vim
│       └── tex_compile.vim
└── personal
    ├── ...
    └── tex-compile-scripts
        ├── compile-show.sh
        ├── compile.sh
        └── forward-show.sh
```


### Main shell script
I keep this file at `nvim/personal/tex-compile-scripts/compile-tex.sh`, but the location is arbitrary as long as you can specify a path to the script. Although I do suggest keeping them somewhere in your Vim directory.
```
#!/bin/sh
# This file lives at nvim/personal/tex-compile-scripts/compile.sh
# A simple shell script for compiling LaTeX files
# The script essentially builds up a pdflatex or latexmk command 
# stored in a string variable, then executes ${command} "myfile.tex"

# Arguments:
# $1: path to file's parent directory (without a trailing forward slash) 
      relative to Vim's current working directory.
#     Use "." if compiled file is in Vim's cwd 
# $2: file name without extension
#     e.g. "myfile" if editing myfile.tex
# $3: boolean 0/1 controlling latexmk or pdflatex compile
#     1 for latexmk
#     0 for pdflatex (anything other than 1 also works)
# $4: boolean 0/1 controlling shell escape compilation
#     1 for -shell-escape enabled
#     0 for -shell-escape disabled (anything other than 1 also works)

# set options for pdflatex and latexmk
# note that most latexmk options are already specified in ~.config/latexmk/latexmkrc
pdflatex_options="-file-line-error -interaction=nonstopmode -halt-on-error -synctex=1 -output-dir=${1}"
latexmk_options="-pdf -output-directory=${1}"

# test script's argument $3 for compilation with latexmk
# --------------------------------------------- #
if [ ${3} -eq 1 ] 2> /dev/null  # use latexmk
then
  command="latexmk ${latexmk_options}"
else  # use pdflatex
  command="pdflatex ${pdflatex_options}"
fi
# --------------------------------------------- #

# append -shell-escape option to command if ${4} == 1
[ ${4} -eq 1 ] && command="${command} -shell-escape"

# run the compilation command
${command} "${1}/${2}.tex"
```

### Supporting Vimscript
This Vimscript calls the above `compile-tex.sh` script from within Vim.
```
let s:compile_script_path = "~/.config/nvim/personal/tex-compile-scripts/compile-tex.sh"

function! tex_compile#compile() abort
  update
  execute "AsyncRun sh " . expand(s:compile_script_path) . 
        \ " $(VIM_RELDIR)" . " $(VIM_FILENOEXT) " . 
        \ expand(b:tex_compile_use_latexmk) . " " . 
        \ expand(b:tex_compile_use_shell_escape)
endfunction
```
Using `:update` to write tex buffer if needed before compilation


## Implementation: error message parsing
- Folder structure is `nvim/personal/tex-compile-scripts/errorformat.vim`. I keep `errorformat` functionality in a dedicated file to declutter `ftplugin/tex.vim`. Your choice.

- Theory: `errorformat` was originally designed to work with Vim's compilation functionality (see `help compiler`). A compiler's logging output is filtered through with `errorformat`, which detects relevant error messages and turns them into a format that makes it easy to jump to the error location in the offending source file. Error format uses the same function as the C function `scanf`.
  
  See `help errorformat` for documentation.

- Source: this `errorformat` is taken from GitHub user `lervag`'s [vimtex plugin](https://github.com/lervag/vimtex).
  
  The original values are found in the Vimscript function `s:qf.set_errorformat()` in the file `vimtex/autoload/vimtex/qf/latexlog.vim`. At the time of writing, the exact source code can be found on the [`vimtex` GitHub page](https://github.com/lervag/vimtex/blob/master/autoload/vimtex/qf/latexlog.vim#L25), although the line number I have linked could change in future `vimtex` releases.

## Implementation: detecting `minted` and using `--shell-escape`
```
let b:tex_compile_use_shell_escape = 0

" Enable b:tex_compile_use_shell_escape if the minted package is detected in the tex file's preamble
" --------------------------------------------- "
silent execute '!sed "/\\begin{document}/q" ' . expand('%') . ' | grep "minted" > /dev/null'
if v:shell_error  " 'minted' not found in preamble
  let b:tex_compile_use_shell_escape = 0  " disable shell escape
else  " 'minted' found in preamble
  let b:tex_compile_use_shell_escape = 1  " enable shell escape
endif
" --------------------------------------------- "
```
On the command line, without all the extra Vimscript quotes and stuff, the `sed` and `grep` call would read
```
sed "/\\begin{document}/q" myfile.tex | grep "minted" > /dev/null
```

Toggling shell escape
```
let b:tex_compile_use_shell_escape = 0  " declare boolean-style variable

" function for toggling shell escape
function! tex_compile#toggle_shell_escape() abort
  if b:tex_compile_use_shell_escape  " if shell escape is on, turn it off
    let b:tex_compile_use_shell_escape = 0
  else  " if shell escape is off, turn it on
    let b:tex_compile_use_shell_escape = 1
  endif
endfunction

" create a <Plug>-style mapping
noremap <Plug>TexToggleShellEscape :call tex_compile#toggle_shell_escape()<CR>
nmap <leader>te <Plug>TexToggleShellEscape
```

## Implementation: toggling compilation with `latexmk`
```
let b:tex_compile_use_latexmk = 0  " declare boolean-style variable

" function for toggling latexmk
function! tex_compile#toggle_latexmk() abort
  if b:tex_compile_use_latexmk  " if latexmk is on, turn it off
    let b:tex_compile_use_latexmk = 0
  else  " if latexmk is off, turn it on
    let b:tex_compile_use_latexmk = 1
  endif
endfunction

" create a <Plug>-style mapping
noremap <Plug>TexToggleLatexmk :call tex_compile#toggle_latexmk()<CR>
nmap <leader>tl <Plug>TexToggleLatexmk
```
