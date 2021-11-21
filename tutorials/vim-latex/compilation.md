---
title: Compilation | Vim and LaTeX Part 1
---
# Compiling LaTeX Documents in a Vim-Based Workflow

## About the series
This is part two in a [four-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents. This article covers compilation and should explain everything you need to get started compiling LaTeX documents from within Vim, either with customized scripts or using the `vimtex` plugin's compilation features.

## Contents of this article
<!-- vim-markdown-toc Marked -->

* [Material covered in this article](#material-covered-in-this-article)
* [What options to use with `pdflatex` and `latexmk`](#what-options-to-use-with-`pdflatex`-and-`latexmk`)
  * [About pdflatex and latexmk](#about-pdflatex-and-latexmk)
  * [Options for pdflatex](#options-for-pdflatex)
  * [Options for latexmk](#options-for-latexmk)
  * [You can use other options, too...](#you-can-use-other-options,-too...)
* [Implementing compilation scripts and Vim functions](#implementing-compilation-scripts-and-vim-functions)
  * [Naive implementation](#naive-implementation)
  * [Asynchronous commands with AsyncRun](#asynchronous-commands-with-asyncrun)
  * [Outsourcing compilation to shell scripts](#outsourcing-compilation-to-shell-scripts)
  * [My compilation shell script](#my-compilation-shell-script)
  * [Supporting Vimscript...](#supporting-vimscript...)
    * [...and a verbose explanation](#...and-a-verbose-explanation)
  * [Toggling compilation with `latexmk`](#toggling-compilation-with-`latexmk`)
  * [Implementing detecting `minted` and using `--shell-escape`](#implementing-detecting-`minted`-and-using-`--shell-escape`)
  * [Implementing error message parsing](#implementing-error-message-parsing)

<!-- vim-markdown-toc -->

## Material covered in this article
- The `pdflatex` and `latexmk` commands and what options to use with each

- Custom Vimscript functions for compiling the current `tex` source file using either `pdflatex` or `latexmk`, controlled from within Vim with a keyboard shortcut of your choice

- How to make compilation run as an *asynchronous* process, keeping focus in Vim throughout compilation (so you don't have to wait until compilation finishes to be able to type.)

- A way to display compilation error messages, with line number, in Vim's QuickFix menu, allowing you to jump directly to the error with Vim's `:cnext` command; how to filter out irrelevant log messages with an approriate Vim `errorformat` string customized for LaTeX compilation.

And also some features of secondary importance:

- A toggle function for switching between `latexmk` and `pdflatex` compilation mapped to convenient keyboard shortcut of your choice.

- For `minted` package users: I occasionally use the `minted` package for including highlighted code blocks in my LaTeX documents. The `minted` package only works if the `tex` source file is compiled with the `--shell-escape` option enabled. Thus, this article shows how to implement:
  1. a script that parses a just-opened `tex` document for occurrences of the `minted` package and automatically enables compilation with `--shell-escape` if `minted` is detected.
  2. a toggle function for turning `--shell-escape` off or on, mapped to convenient keyboard shortcut of your choice.


## What options to use with `pdflatex` and `latexmk`

### About pdflatex and latexmk
Both `pdflatex` and `latexmk` are command line programs that read a plain-text `.tex` file as input and produce a PDF file as output. The process of turning plain text into a PDF is called *compilation*. The `pdflatex` program ships by default with any standard LaTeX installation; `latexmk` is a Perl script used to fully automate compiling complicated LaTeX documents with cross-references and bibliographies. The `latexmk` script actually calls `pdflatex` (or similar programs) under the hood, and automatically determines exactly how many `pdflatex` runs are needed to properly compile a document.

Online and GUI LaTeX editors you might already know, such as Overleaf, TeXShop or TeXStudio, also compile `tex` documents with `latexmk` or `pdflatex` (or similar command line programs) under the hood. You just don't see this directly because the `pdflatex` calls are hidden behind a graphical interface.

  To get useful functionality from `pdflatex` and `latexmk` you'll need to specify some command options. In the two sections below, I explain the options for both `pdflatex` and `latexmk` that have served me well over the past few years---these could be a good starting point if you are new to command line compilation yourself.

### Options for pdflatex
The full `pdflatex` command I use to compile `tex` files, with all options shown, is
  ```
  pdflatex -file-line-error -halt-on-error -interaction=nonstopmode -output-dir={output-directory} -synctex=1 {sourcefile.tex}
  ```
  where
  - `{sourcefile.tex}` would be the full path to the `tex` file you wish to compile (e.g. `~/Documents/myfile.tex`), and
  - `{output-directory}` would be the full path to the directory you want the output files to go (generally the parent directory of `sourcefile.tex`)

You can find full documentation of `pdflatex` options by running `man pdflatex` in a terminal; for our purposes, here is an explanation of each option used above:
- `-file-line-error` prints error  messages in the form `file:line:error`. Here is an example of what `pdflatex` reports if I incorrectly leave out the `\item` command in an `itemize` environment on line 15 of the file `test.tex`:
  ```
  ././test.tex:15: LaTeX Error: Something's wrong--perhaps a missing \item.
  ```
  The format used by `-file-line-error` makes it easier to parse error messages using Vim's `errorformat` functionality, which is covered in more detail below at **[Implementing error message parsing](#implementing-error-message-parsing)**.

- `-halt-on-error` exits `pdflatex` immediately if an error is encountered during compilation (instead of attempting to continue compiling the document in spite of the error)

- `-interaction=nonstopmode` sets `pdflatex`'s run mode to not stop on errors. The idea is to use `-interaction=nonstopmode` *together* with `-halt-on-error`  to halt compilation at the first error and return control to the parent process/program from which `pdflatex` was run.

  If you're curious for official documentation of the other possible values of the `interaction` option: in a terminal, run `texdoc texbytopic`, which opens a PDF manual. In the PDF, search for the chapter `Running TeX` (chapter 32 at the time of writing) and find the subsection `Run modes` (subsection 32.2 at the time of writing), where you will find TeX's run modes explained; the possible values of the `-interaction` option for `pdflatex` have the same effect.

- `-output-dir={output-directory}` writes the files outputed by the compilation process into the directory `output-directory` (instead of the current working directory from which `pdflatex` was run). I set `directory` equal to the parent directory of the to-be-compiled `tex` file; e.g. to compile `~/Documents/tex-files/myfile.tex` I would use `output-directory=~/Documents/tex-files`.

- `synctex=1` generates SyncTeX data for the compiled file, which enables inverse search between a PDF reader and the `tex` source file; more on this in the article [integrating a PDF reader and Vim]({% link tutorials/vim-latex/pdf-reader.md %}).

  Using `synctex=1` saves the `synctex` data in a `gz` archive with the extension `.synctex.gz`. Possible values of the `synctex` argument other than `1` are documented under `man synctex`

### Options for latexmk
When compiling `tex` files with `latexmk` instead of with `pdflatex`, I use the command
```
latexmk -pdf -output-directory={output-directory}
```
*together with the following* `latexmkrc` *file*:
```sh
# this file lives at ~/.config/latexmk/latexmkrc
# and contains the single line...
$pdflatex = "pdflatex -file-line-error -halt-on-error -interaction=nonstopmode -synctex=1";
```
First, regarding the options in the `latexmk` call:
- `-pdf` tells `latexmk` to compile using `pdflatex`, which creates a PDF output file.

- `-output-dir={output-directory}` has the same role as in the section [**Options for pdflatex**](#options-for-pdflatex).

The `latexmkrc` file configures `latexmk`'s default behaviour; the `$pdflatex = "..."` line in my `latexmkrc` specifies the options `latexmk` should use when using `pdflatex` for compilation. This saves specifying `pdflatex` options by hand on every `latexmk` call. Note that these options match the options for the vanilla `pdflatex` calls described in the [**Options for pdflatex**](#pdflatex) section. 

You should put your `latexmkrc` file either at:
- `~/.latexmkrc`, or 
- `~/.config/latexmk/latexmkrc` (or `XDG_CONFIG_HOME/latexmk/latexmkrc` if you use `XDG_CONFIG_HOME`).

The `latexmkrc` file's usage is documented in `man latexmkrc` under the section `CONFIGURATION/INITIALIZATION (RC) FILES`. The `latexmk` program is well-documented in general; see`man latexmk` for far more information than is covered here, including the possibility of fancy features like continuous compilation.

### You can use other options, too...
The `pdflatex` and `latexmk` commands and options described above are just the tip of the iceberg, and by no means the definitive way to compile LaTeX documents. Consider them a starting point based on what has served me well during my undergraduate studies. I encourage you to read through the `pdflatex` and `latexmk` documentation and experiment with what works for you.

## Implementing compilation scripts and Vim functions
Here is the big picture:

> We need a convenient way to call `pdflatex` or `latexmk`, which are *command-line programs* (and are usually run as shell commands from a terminal emulator), from *within Vim*.

Vim, being a good Unix citizen, offers a variety of options for running shell commands from within Vim---some of these are explained in the sections below.

### Naive implementation
The simplest way to execute shell commands from Vim is Vim's `:!{command}` functionality, which is documented at `:help :!cmd`. The process is straightforward: 

1. in normal mode, enter `:` to enter Vim's command mode
1. type `!`
1. type a shell command and press Enter.

For example, running `:!pdflatex myfile.tex` from Vim's command-line mode has the same effect as running `pdflatex myfile.tex` in a terminal emulator.

### Asynchronous commands with AsyncRun
- Problem: Vim's built-in `:!{command}` functionality runs synchronously---this means Vim freezes until the shell command finishes executing. Compiling LaTeX documents can take several seconds, and this delay is unacceptable. Try running `:!pdflatex %` on a LaTeX file and see for yourself (`%` is a Vim macro for the current file).

- Hacked solution: run the command in the background with `:!{command}&`. This works only on Unix systems and won't show any output. 

- Actual solution: use an *asynchronous build plugin*.

Asynchronous build plugins allow you to run shell commands asynchronously from within Vim without freezing up your editor. The most famous is probably Tim Pope's [`vim-dispatch`](https://github.com/tpope/vim-dispatch), but in this series I will use [skywind300](https://github.com/skywind3000)'s [asyncrun.vim](https://github.com/skywind3000/asyncrun.vim).

You install AsyncRun, with the installation method of your choice, just like any other Vim plugin (see **TODO** prequisites). AsyncRun provides the `:AsyncRun` command, which is an asynchronous equivalent of `:!`. For example:
```vim
:! pdflatex myfile.tex         " runs synchronously
:AsyncRun pdflatex myfile.tex  " runs asynchronously
```
That's it, more or less---the compilation commands later in this article are either variations on `:AsyncRun pdflatex myfile.tex` with a few more options thrown in, or calls to a shell script, as in `:AsyncRun sh my-compile-script.sh my-file.tex`.

### Outsourcing compilation to shell scripts
Since `pdflatex` and `latexmk` are command line programs at home in the shell, I manage most of my compilation with shell scripts. I then call these shell scripts asynchronously with one-liner Vimscript functions using `:AsyncRun`.

First, here is my directory structure:
```
nvim/
├── ...
├── ftplugin/
│   ├── ...
│   └── tex/
│       ├── errorformat.vim
│       ├── tex.vim
│       └── tex-compile.vim
└── personal/
    ├── ...
    └── tex-scripts
        ├── compile.sh
        └── forward-show.sh
```
The script `compile.sh` implements compilation; `forward-show.sh` is explained in **TODO** reference PDF reader.

### My compilation shell script
My compilation script appears below. Like the rest of my config, it is by no means the best or definitive way to compile LaTeX documents, but it should be a good starting point for new users. I keep this file at `nvim/personal/tex-compile-scripts/compile.sh`, but the location is arbitrary as long as you can specify a path to the script. All I suggest is keeping it somewhere in your Vim directory.
```sh
#!/bin/sh
# This script lives at nvim/personal/tex-compile-scripts/compile.sh

# A simple shell script for compiling LaTeX files.
# The script essentially builds up a pdflatex or latexmk command 
# stored in a string variable, then executes ${command} "myfile.tex".

# Arguments:
# $1: path to file's parent directory (without a trailing forward slash) 
      relative to Vim's current working directory.
#     Use "." if compiled file is in Vim's cwd 
# $2: file name with extension but without path
#     e.g. "myfile.tex" if editing ~/Documents/demo/myfile.tex
# $3: boolean 0/1 controlling latexmk or pdflatex compile
#     1 for latexmk
#     0 for pdflatex (anything other than 1 also uses pdflatex)
# $4: boolean 0/1 controlling shell escape compilation
#     1 for shell-escape enabled
#     0 for shell-escape disabled (anything other than 1 also works)

# Set options for pdflatex and latexmk
# Note that most latexmk options are already specified in ~.config/latexmk/latexmkrc
pdflatex_options="-file-line-error -interaction=nonstopmode -halt-on-error -synctex=1 -output-dir=${1}"
latexmk_options="-pdf -output-directory=${1}"

# test script's argument $3 for compilation with latexmk
# --------------------------------------------- #
if [ ${3} -eq 1 ]  # use latexmk
then
  command="latexmk ${latexmk_options}"
else  # use pdflatex
  command="pdflatex ${pdflatex_options}"
fi
# --------------------------------------------- #

# append shell-escape option to command if ${4} == 1
[ ${4} -eq 1 ] && command="${command} -shell-escape"

# run the compilation command on the tex source file
${command} "${1}/${2}"
```
If you are familiar with shell scripting, the script should be fairly straightforward. 

And some pointers for those totally new to shell scripting:

- a variable's value is accessed with `${variable-name}`, e.g. `${3}` gives the value of the script's third argument, and `${command}` gives the value of the `command` variable
- `if [ condition ]`, e.g. `if [ ${3} -eq 1 ]`, is the shell analog of the `if(condition)` statements you might be familiar with from other languages
- `~` is shorthand for the current user's home directory
- `.` is shorthand for the current working directory

### Supporting Vimscript...
The following Vimscript, which I keep in `nvim/ftplugin/tex/tex-compile.vim`, calls the `compile.sh` script from within Vim.
```vim
" This code lives in ~/.config/nvim/ftplugin/tex/tex-compile.vim

let s:compile_script_path = "$HOME/.config/nvim/personal/tex-scripts/compile.sh"

function! s:TexCompile() abort
  update
  execute "AsyncRun sh " . expand(s:compile_script_path) . 
        \ " $(VIM_RELDIR)" .
        \ " $(VIM_FILENAME) " . 
        \ expand(b:tex_compile_use_latexmk) . " " . 
        \ expand(b:tex_compile_use_shell_escape)
endfunction

" key mapping to call TexCompile; I use <leader>r for "run"
nmap <leader>r <Plug>TexCompile
noremap <script> <Plug>TexCompile <SID>TexCompile
noremap <SID>TexCompile :call <SID>TexCompile()<CR>
```
#### ...and a verbose explanation
In the hope of making this accessible even to new Vim users, here is a detailed explanation of the above Vimscript:
- `update` writes the buffer if there are any unsaved changes.
- I store the path to `compile.sh` in the script-local variable `s:compile_script_path`. This is just for cleaner code, and to make it easier to access `compile.sh` from other places in the `tex-compile.vim` file.
- `.` is the Vimscript string concatenation operator---the analog of `+` in Python or Java, for example.
- `\` continues an existing expression on a new line. I use it to keep each `compile.sh` argument on its own line for better readability. For example: the following two expressions are equivalent, but the latter is easier to read, I think:
  ```vim
  " one long line
  execute "AsyncRun sh " . expand(s:compile_script_path) . " $(VIM_RELDIR)" . " $(VIM_FILENAME) " . expand(b:tex_compile_use_latexmk) . " " . expand(b:tex_compile_use_shell_escape)

  " one argument per line
  execute "AsyncRun sh " . expand(s:compile_script_path) . 
        \ " $(VIM_RELDIR)" .
        \ " $(VIM_FILENAME) " . 
        \ expand(b:tex_compile_use_latexmk) . " " . 
        \ expand(b:tex_compile_use_shell_escape)
  ```
  Each line provides one of the arguments for the `compile.sh` script---scroll back up to [**My compilation shell script**](#my-compilation-shell-script) for a refresher of these arguments if needed.

  The variables `b:tex_compile_use_latexmk` and `b:tex_compile_use_shell_escape` control `latexmk` and shell-escaped compilation, and are described below in **TODO** reference.

- `expand({expression})` expands the Vimscript `{expression}` into (in this use case) a string; for example, `expand(s:compile_script_path)` returns the string value of the `s:compile_script_path` variable.

- `$(VIM_RELDIR)` and `$(VIM_FILENAME)` are examples of convenient macros provided by AsyncRun. They expand to:

  - `$(VIM_FILENAME)`: the name, with extension but without path, of the file currently edited in Vim.
    
    Example: `myfile.tex` if editing `~/Documents/demo/myfile.tex`

  - `$(VIM_RELDIR)`: path to the file currently edited in Vim *relative to* Vim's current working directory. This is Vim's CWD if editing a file in the directory you launched Vim, but will be something else if you navigate to some other file in an existing Vim instance.

    Example: `.` if the current file is in Vim's CWD, and, say, `../other-folder` if, after launching Vim, you called `:edit ../other-folder/file2.tex` and began editing `file2.tex`.

  All `AsyncRun` macros are documented at `:help asyncrun-run-shell-command`---just scroll a few paragraphs down.

  **Note:** *the* `$(VIM_*)` *macros are provided by AsyncRun and not by default Vim, so if you want to follow this tutorial exactly, you will need to install AsyncRun.*


- The Vimscript block
  ```vim
  nmap <leader>r <Plug>TexCompile
  noremap <script> <Plug>TexCompile <SID>TexCompile
  noremap <SID>TexCompile :call <SID>TexCompile()<CR>
  ```
  makes it possible to call the `TexCompile()` function using the key combination `<leader>r` in normal mode. Roughly, the use of `<Plug>` and `<SID>` is a best practice recommended by the Vim documentation in `:help write-plugin` to prevent the (unlikely) possibility of `TexCompile()` conflicting with a function name of the same name in some other script. See **TODO** for an explanation of the underlying theory.

### Toggling compilation with `latexmk`
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

### Implementing detecting `minted` and using `--shell-escape`
Note: feel free to skip this section if you don't use `minted` for code highlighting and have no needed for `shell-escape` compilation.
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


### Implementing error message parsing
- Folder structure is `nvim/personal/tex-compile-scripts/errorformat.vim`. I keep `errorformat` functionality in a dedicated file to declutter `ftplugin/tex.vim`. Your choice.

- Theory: `errorformat` was originally designed to work with Vim's compilation functionality (see `help compiler`). A compiler's logging output is filtered through with `errorformat`, which detects relevant error messages and turns them into a format that makes it easy to jump to the error location in the offending source file. Error format uses the same function as the C function `scanf`.
  
  See `help errorformat` for documentation.

- Source: this `errorformat` is taken from GitHub user [`lervag`](https://github.com/lervag)'s [`vimtex`](https://github.com/lervag/vimtex) plugin.
  
  The original values are found in the Vimscript function `s:qf.set_errorformat()` in the file `vimtex/autoload/vimtex/qf/latexlog.vim`. At the time of writing, the exact source code can be found on the [`vimtex` GitHub page](https://github.com/lervag/vimtex/blob/master/autoload/vimtex/qf/latexlog.vim#L25), although the line number I have linked could change in future `vimtex` releases.

- Note `let g:asyncrun_trim = 1` to avoid empty lines in the quickfix list

- The `%` is documented at `:help cmdline-special`

