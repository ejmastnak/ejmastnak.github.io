---
title: Compilation | Vim and LaTeX Part 1
---
# Compiling LaTeX Documents in a Vim-Based Workflow

## About the series
This is part two in a [four-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents. This article covers compilation and should explain everything you need to get started compiling LaTeX documents from within Vim, either with customized scripts or using the `vimtex` plugin's compilation features.

## Contents of this article

<!-- vim-markdown-toc GFM -->

* [Material covered in this article](#material-covered-in-this-article)
* [How to use `pdflatex` and `latexmk`](#how-to-use-pdflatex-and-latexmk)
  * [About pdflatex and latexmk](#about-pdflatex-and-latexmk)
  * [Possible options for pdflatex](#possible-options-for-pdflatex)
  * [Possible options for latexmk](#possible-options-for-latexmk)
  * [You can use other options, too...](#you-can-use-other-options-too)
  * [Warning: compiling when using the minted package](#warning-compiling-when-using-the-minted-package)
* [Writing a simple LaTeX compiler plugin](#writing-a-simple-latex-compiler-plugin)
  * [File structure](#file-structure)
  * [Aside: Vim's file macros](#aside-vims-file-macros)
  * [Setting Vim's makeprg](#setting-vims-makeprg)
  * [Toggling between pdflatex and latexmk compilation](#toggling-between-pdflatex-and-latexmk-compilation)
  * [Implementing error message parsing](#implementing-error-message-parsing)
* [Asynchronous compilation with `vim-dispatch`](#asynchronous-compilation-with-vim-dispatch)
* [Appendix](#appendix)
  * [Implementing `minted` detection and using `--shell-escape`](#implementing-minted-detection-and-using---shell-escape)
  * [Complete compiler plugin](#complete-compiler-plugin)

<!-- vim-markdown-toc -->


## Material covered in this article
- The basics of the `pdflatex` and `latexmk` commands and suggested options to use with each

- How to set up custom compilation, with either `pdflatex` or `latexmk`,  using Vim's built `compiler` feature; how to trigger compilation from withing Vim with a convenient keyboard shortcut of your choice

- How to make compilation run as an *asynchronous* process, keeping focus in Vim throughout compilation (so you don't have to wait until compilation finishes to restart your editing)

- A way to display compilation error messages, with line number, in Vim's QuickFix menu, allowing you to jump directly to the error with Vim's `:cnext` command; how to filter out irrelevant log messages with an approriate Vim `errorformat` string customized for LaTeX compilation.

And also some features of secondary importance:

- A toggle function for switching between `latexmk` and `pdflatex` compilation mapped to convenient keyboard shortcut of your choice.

- For `minted` package users: I occasionally use the `minted` package for including highlighted code blocks in my LaTeX documents. The `minted` package only works if the `tex` source file is compiled with the `--shell-escape` option enabled. Thus, this article shows how to implement:
  1. a script that parses a just-opened `tex` document for occurrences of the `minted` package and automatically enables compilation with `--shell-escape` if `minted` is detected.
  2. a toggle function for turning `--shell-escape` off or on, mapped to convenient keyboard shortcut of your choice.


## How to use `pdflatex` and `latexmk`
If you already know how to use `pdflatex` and `latexmk`, feel free to jump ahead to the section [Writing a simple LaTeX compiler plugin](#writing-a-simple-latex-compiler-plugin).

### About pdflatex and latexmk
Both `pdflatex` and `latexmk` are command line programs that read a plain-text `.tex` file as input and produce a PDF file as output. The process of turning plain text into a PDF is called *compilation*. The `pdflatex` program ships by default with any standard LaTeX installation; `latexmk` is a Perl script used to fully automate compiling complicated LaTeX documents with cross-references and bibliographies. The `latexmk` script actually calls `pdflatex` (or similar programs) under the hood, and automatically determines exactly how many `pdflatex` runs are needed to properly compile a document.

Online and GUI LaTeX editors you might already know, such as Overleaf, TeXShop or TeXStudio, also compile `tex` documents with `latexmk` or `pdflatex` (or similar command line programs) under the hood. You just don't see this directly because the `pdflatex` calls are hidden behind a graphical interface.

  To get useful functionality from `pdflatex` and `latexmk` you'll need to specify some command options. In the two sections below, I explain the options for both `pdflatex` and `latexmk` that have served me well over the past few years---these could be a good starting point if you are new to command line compilation.

### Possible options for pdflatex
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

### Possible options for latexmk
When compiling `tex` files with `latexmk` instead of with `pdflatex`, I use the command
```
latexmk -pdf -output-directory={output-directory} {sourcefile.tex}
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
The `pdflatex` and `latexmk` commands and options described above are by no means the definitive way to compile LaTeX documents. Consider them a starting point based on what has served me well during my undergraduate studies. I encourage you to read through the `pdflatex` and `latexmk` documentation and experiment with what works for you.

### Warning: compiling when using the minted package
The [`minted` package](https://github.com/gpoore/minted) provides expressive syntax highlighting for LaTeX documents, which is useful when you include samples of computer code in your LaTeX documents. (If you don't use `minted`, feel free to skip this section.)

**TODO** image of a code block highlighted with `minted`.

The `minted` package works by leveraging the [Pygments syntax highlighting library](https://github.com/pygments/pygments). *For `minted` to be able to use Pygments during compilation, you must compile with `pdflatex` or `latexmk`'s `-shell-escape` option*. A `pdflatex` call with `-shell-escape` enabled might look like this:
```sh
pdflatex -shell-escape myfile.tex
```
However, as warned in Section 3.1 (Basic Usage/Prelminary) of the [`minted` documentation](http://tug.ctan.org/macros/latex/contrib/minted/minted.pdf), using `-shell-escape` is a security risk:

> using `-shell-escape` allows LaTeX to run potentially
arbitrary commands on your system. It is probably best to use `-shell-escape`
only when you need it, and to use it only with [LaTeX] documents from trusted sources.

Basically the lessons here are:
- if you want highlighted code blocks, use the `minted` package
- for `minted` to work, you must enable `-shell-escape` during compilation
- only use `-shell-escape` if you're sure your LaTeX document doesn't contain or call malicious code, and disable `-shell-escape` if you don't need it. (Of course, if you wrote the LaTeX document yourself, you should have nothing to worry about.)

The idea of dangerous LaTeX code might sound silly (why would anyone include malicious code in a LaTeX document?) but keep it in mind anyway.

## Writing a simple LaTeX compiler plugin

Here is the big picture:

> We need a convenient way to call `pdflatex` or `latexmk`, which are *command-line programs* (and are usually run as shell commands from a terminal emulator), from *within Vim*.

Vim has a built-in `compiler` feature for doing just that. For full documentation, you can read through `:help :compiler`, `:help make_makeprg`, `:help makeprg` and `:help write-compiler-plugin`. For our purposes, at least for getting started,
- Vim has a built-in system for easily compiling documents using shell commands of your choice.
- You use Vim's `makeprg` option to store the shell command you want to use to compile a document.
- You use Vim's `errorformat` option to specify how to parse the compilation command's output log for errors.
- You use Vim's `:make` command to trigger the compilation command stored in `makeprg`
- You can view the command's output, along with any errors, in an IDE-style QuickFix menu built in to Vim, which you can open with `:copen`.

Here is a GIF showing what this looks like in practice: **TODO** definitely a GIF showing `:make` and how the Quickfix menu opens.

Here's what we will cover in this section:
- How to translate the `pdflatex` and `latexmk` commands from **TODO** reference into something understood by Vim's `makeprg` option
- Writing a Vimscript function for easily switching between `pdflatex` and `latexmk` compilation, and mapping this to a convenient keyboard shortcut
- Setting Vim's `errorformat` option to correctly parse LaTeX errors
- For `minted` package users, a Vimscript function for easily toggling `-shell-escape` compilation on and off; also, a simple way to detect the `minted` package in a file's preamble and enable `-shell-escape` compilation if `minted` is detected

If you just want to see the final script, you can jump to the section [Complete compiler plugin](#complete-compiler-plugin).

### File structure
Compiler plugins should be stored in Vim's `.vim/compiler` directory---you might need to create a `compiler` directory if you don't have one yet. For a LaTeX compiler plugin, create the file `vim/compiler/tex.vim` (you could name it whatever you want, e.g. `mytex.vim`, but the target file type---in this case `tex`---is conventional).

**TODO** add my directory tree.


### Aside: Vim's file macros
To compile a file, you need to specify the file's name. Vim provides a set of macros and modifiers that makes it easy to reference the current file, but the syntax is a little weird if you haven't seen it before. It might be easiest with a concrete example: consider a LaTeX file with the path `~/Documents/demo/myfile.tex`, and suppose Vim was launched from inside `~/Documents/demo/` to edit `myfile.tex` (so that Vim's working directory is `~/Documents/demo`). In this case...

| Macro | Meaning | Example result |
| ----- | ------- | -------------- |
| `%` | the current file relative to Vim's working directory | `myfile.tex` |
| `%:p` | the current file expressed as a full path | `~/Documents/demo/myfile.tex` |
| `%:h` | the file's parent directory relative to Vim's working directory | `.` |
| `%:r` | the file's root (last extension removed) | `myfile` |

The macros and their modifiers can also be combined, for example:

| Macro | Meaning | Example result |
| ----- | ------- | -------------- |
| `%:p:h` | full path to file's parent directory | `~/Documents/demo` |
| `%:p:r` | full path to file's parent directory | `~/Documents/demo/myfile` |

There's quite a few more modifiers than listed above, but these are all we need for this series. You can read more about `%` in `:kelp cmdline-special` and the various modifiers in `:help filename-modifiers`. For orientation, you can evaluate the macro expressions yourself with, for example, `:echo expand('%')` or `:echo expand(%:p:h)`.

**Compilation commands using Vim filename macros**

Original values from **TODO** reference
```sh
pdflatex -file-line-error -halt-on-error -interaction=nonstopmode -output-dir={output-directory} -synctex=1 {sourcefile.tex}
latexmk -pdf -output-directory={output-directory} {sourcefile.tex}
```
Using Vim's macros, `{output-directory}` is replaced by `%:h` and `{sourcefile.tex}` is replaced with `%`:
```sh
pdflatex -file-line-error -halt-on-error -interaction=nonstopmode -output-dir=%:h -synctex=1 %
latexmk -pdf -output-directory=%:h %
```

### Setting Vim's makeprg
For review, `makeprg` is a Vim option used to store shell-style compilation commands. You have two ways to set `makeprg`:
1. Set `makeprg` directly using `:set` or `:setlocal`, in which case you must escape spaces with `\`. For example, to set `makeprg` to the command `latexmk -pdf -output-directory=%:h %` you would add the following code to `compiler/tex.vim`
   ```vim
   " This code would go in compiler/tex.vim
   setlocal makeprg=latexmk\ -pdf\ -output-directory=%:h\ %
   ```

2. Store the desired value of `makeprg` in a literal Vimscript string (in which case you don't need to escape spaces), then set `makeprg` programatically using Vim's `:let &{option}` feature:
   ```vim
   " This code would go in compiler/tex.vim

   " Create a script-local variable `s:latexmk` to store the latexmk command
   let s:latexmk = 'latexmk -pdf -output-directory=%:h %'

   " set makeprg to the value of 'latexmk'
   let &l:makeprg = expand(s:latexmk)
   ```
   Using `let &l:{option}` is the buffer-local equivalent of `:let &{option}` (just like `:setlocal` is the buffer-local equivalent of `:set`). See `:help :let-&` for documentation.

In either case, once you have set `makeprg`, you can compile the current LaTeX document with the Vim command `:make`. (I recommend checking the value of `makeprg` with `:echo &makeprg` to see that it has changed from its default value of `make` to whatever you set.)
   
### Toggling between pdflatex and latexmk compilation
If you only want to use `latexmk`, feel free to skip this section. Here's why you might want to switch between the two:
- `pdflatex` always performs a single pass. This is fast, but won't always resolve cross-references (I might see a `?` symbol instead of the correct equation number for a `\ref` command, for example). I use `pdflatex` when I want quick visual feedback of text I just edited, but don't need all `\label`, `\ref`, and `\cite` commands to work correctly .
- `latexmk` performs as many compilation passes as needed to perfectly resolve all cross-references. This is slow if you just want basic visual feedback, but vital if you're about to send a paper out for publication.

If you want to toggle between compilation commands, first store the current buffer's `pdflatex`/`latexmk` state in a buffer-local, boolean-like variable, for example `b:tex_compile_use_latexmk`. You can then implement toggle logic as follows:
```vim
" This code would go in compiler/tex.vim

" `makeprg` command values for both pdflatex or latexmk
let s:pdflatex = 'pdflatex -file-line-error -interaction=nonstopmode ' .
      \ '-halt-on-error -synctex=1 -output-directory=%:h %'
let s:latexmk = 'latexmk -pdf -output-directory=%:h %'

" A variable to store pdflatex/latexmk state
" 1 for latexmk and 0 for pdflatex
let b:tex_compile_use_latexmk = 0

" Toggles between latexmk and pdflatex
function! s:TexToggleLatexmk() abort
  if b:tex_compile_use_latexmk  " if latexmk is on, turn it off
    let b:tex_compile_use_latexmk = 0
  else  " if latexmk is off, turn it on
    let b:tex_compile_use_latexmk = 1
  endif
  call s:TexSetMakePrg()  " update makeprg
endfunction

" Sets value of makeprg based on current value of b:tex_compile_use_latexmk
function! s:TexSetMakePrg() abort
  if b:tex_compile_use_latexmk
    let &l:makeprg = expand(s:latexmk)
  else
    let &l:makeprg = expand(s:pdflatex)
  endif
endfunction
```
The code is a lot of lines, but the logic is hopefully straightforward. And here is some Vimscript to map the toggle function to a keyboard shortcut, for example `<leader>tl`:
```vim
" This code would go in compiler/tex.vim

nmap <leader>tl <Plug>TexToggleLatexmk
nnoremap <script> <Plug>TexToggleLatexmk <SID>TexToggleLatexmk
nnoremap <SID>TexToggleLatexmk :call <SID>TexToggleLatexmk()<CR>
```

### Implementing error message parsing
Vim filters the log output of the `makeprg` command through the Vim `errorformat` option, which can detect relevant error messages and turns them into a format that makes it easy to jump to the error location in the offending source file. You can see the details of the `:make` cycle with `:help :make`.

Vim's `errorformat` uses a similar format to the C function `scanf`, which is rather cryptic to new users. I won't cover `errorformat` design in this series, and will only quote some `errorformat` values (taken from the `vimtex` plugin) that should serve most use cases. If inspired, see `:help errorformat` for documentation.

The following `errorformat` is taken from the [`vimtex`](https://github.com/lervag/vimtex) plugin. If you're interested, the original source code can be found on the `vimtex` GitHub page on [line 25 of `vimtex/autoload/vimtex/qf/latexlog.vim`](https://github.com/lervag/vimtex/blob/master/autoload/vimtex/qf/latexlog.vim#L25), although the line number may change in future `vimtex` releases.

```vim
" This code sets errorformat and would go in compiler/tex.vim
" Important: The errorformat used below assumes the tex source file is 
" compiled with pdflatex's -file-line-error option enabled.

" Match file name
setlocal errorformat=%-P**%f
setlocal errorformat+=%-P**\"%f\"

" Match LaTeX errors
setlocal errorformat+=%E!\ LaTeX\ %trror:\ %m
setlocal errorformat+=%E%f:%l:\ %m
setlocal errorformat+=%E!\ %m

" More info for undefined control sequences
setlocal errorformat+=%Z<argument>\ %m

" More info for some errors
setlocal errorformat+=%Cl.%l\ %m

" Catch-all to ignore unmatched lines
setlocal errorformat+=%-G%.%#
```
**Important:** this errorformat will only work if `pdflatex` or `latexmk` are used with the `-file-line-error` option, as suggested in **TODO** reference.

Note, also, if you want to remove output from QuickFix while using Dispatch, in `/after/ftplugin/tex.vim` add
```vim
" This is a hack to force the catch-all %-G%.%# that removes unmatched lines
" There are two problems:
" 1. vim-dispatch intentionally removes the original catch-all; see https://github.com/tpope/vim-dispatch/issues/76#issuecomment-50210286
" 2. Vim "helpfully" filters out errorformat duplicates; setting errorformat+=%-G%.%#
"    wouldn't work, so errorformat+=%-G%.%#,. where the appending ,. does nothing is
"    a hack to force in an extra catchall.
setlocal errorformat+=%-G%.%#,.
```


## Asynchronous compilation with `vim-dispatch`
It's simple: because of how Dispatch is written, the compiler plugin can stay as is.

- Inside `ftplugin/tex.vim` include the line
  ```vim
  compiler tex              " load my user-defined tex compiler
  ```
  Just ensure the argument passed to `:compiler`, in this case `tex`, matches the base filename of your LaTeX compiler plugin in `vim/compiler/`.

- After this use `:Make` in place of `:make` and you're done. Dispatch will pick up your `compiler` settings.

- Optionally create a convenient key mapping
  ```vim
  nnoremap <leader>r :Make<CR>
  ```
  

## Appendix
### Implementing `minted` detection and using `--shell-escape`
Feel free to ignore this section if you don't use `minted` for code highlighting and have no needed for `shell-escape` compilation. The logic for toggling `-shell-escape` on and off is the same as for toggling between `pdflatex` and `latexmk`.
```vim
" variable to store shell-escape state
let b:tex_compile_use_shell_escape = 0

" Toggles shell escape compilation on and off
function! s:TexToggleShellEscape() abort
  if b:tex_compile_use_shell_escape  " turn off shell escape
    let b:tex_compile_use_shell_escape = 0
  else  " turn on shell escape
    let b:tex_compile_use_shell_escape = 1
  endif
  call s:TexSetMakePrg()  " update makeprg
endfunction
```
The `TexSetMakePrg` function would need to be generalized to
```vim
" Sets the value of makeprg based on current values of both
" b:tex_compile_use_latexmk and b:tex_compile_use_shell_escape.
function! s:TexSetMakePrg() abort
  if b:tex_compile_use_latexmk
    let &l:makeprg = expand(s:latexmk)
  else
    let &l:makeprg = expand(s:pdflatex)
  endif
  if b:tex_compile_use_shell_escape
    let &l:makeprg = &makeprg . ' -shell-escape'
  endif
endfunction
```

**A simple way to automaticlly detect `minted`**

Finally, here is a (naive but functional) way to detect `minted` using the Unix utilities `sed` and `grep`:
```
" initialize to zero (i.e. shell escape off)
let b:tex_compile_use_shell_escape = 0

" Enable b:tex_compile_use_shell_escape if the minted package is detected in the tex file's preamble
silent execute '!sed "/\\begin{document}/q" ' . expand('%') . ' | grep "minted" > /dev/null'
if v:shell_error  " 'minted' not found in preamble
  let b:tex_compile_use_shell_escape = 0  " disable shell escape
else  " search was successful; 'minted' found in preamble
  let b:tex_compile_use_shell_escape = 1  " enable shell escape
endif
```
On the command line, without all the extra Vimscript jargon, the `sed` and `grep` call would read
```
sed "/\\begin{document}/q" myfile.tex | grep "minted" > /dev/null
```
The `sed` call reads the file's preamble (and quits at `\begin{document}`), and the output is piped into a `grep` search for the string `"minted"`. I then use Vim's `v:shell_error` variable to check the `grep` command's exit status---if the search is successful, I update `b:tex_compile_use_shell_escape`'s value to enable shell escape.

This command is naive, I'm sure. It's probably inefficient and won't work, for example, if you keep your preamble in a separate file and access it with the `\input` command. If you know a better way, e.g. using `awk`, please tell me and I'll update this article.

### Complete compiler plugin
```vim
" Settings for compiling LaTeX documents
if exists("current_compiler")
	finish
endif
let current_compiler = "tex"

" make programs using pdflatex or latexmk
let s:pdflatex = 'pdflatex -file-line-error -interaction=nonstopmode ' .
      \ '-halt-on-error -synctex=1 -output-directory=%:h %'
let s:latexmk = 'latexmk -pdf -output-directory=%:h %'

" used to toggle latexmk and shell-escape compilation on and off
let b:tex_compile_use_latexmk = 0
let b:tex_compile_use_shell_escape = 0


" Search for the minted package in the document preamble.
" Enable b:tex_compile_use_shell_escape if the minted package
" is detected in the tex file's preamble.
" --------------------------------------------- "
silent execute '!sed "/\\begin{document}/q" ' . expand('%') . ' | grep "minted" > /dev/null'
if v:shell_error  " 'minted' not found in preamble
  let b:tex_compile_use_shell_escape = 0  " disable shell escape
else  " 'minted' found in preamble
  let b:tex_compile_use_shell_escape = 1  " enable shell escape
endif


" User-defined functions
" ------------------------------------------- "
" Toggles between latexmk and pdflatex
function! s:TexToggleLatexmk() abort
  if b:tex_compile_use_latexmk  " turn off latexmk
    let b:tex_compile_use_latexmk = 0
  else  " turn on latexmk
    let b:tex_compile_use_latexmk = 1
  endif
  call s:TexSetMakePrg()  " update makeprg
endfunction

" Toggles shell escape compilation on and off
function! s:TexToggleShellEscape() abort
  if b:tex_compile_use_shell_escape  " turn off shell escape
    let b:tex_compile_use_shell_escape = 0
  else  " turn on shell escape
    let b:tex_compile_use_shell_escape = 1
  endif
  call s:TexSetMakePrg()  " update makeprg
endfunction

" Sets correct value of makeprg based on current values of 
" b:tex_compile_use_latexmk and b:tex_compile_use_shell_escape
function! s:TexSetMakePrg() abort
  if b:tex_compile_use_latexmk
    let &l:makeprg = expand(s:latexmk)
  else
    let &l:makeprg = expand(s:pdflatex)
  endif
  if b:tex_compile_use_shell_escape
    let &l:makeprg = &makeprg . ' -shell-escape'
  endif
endfunction


" Key mappings for functions
" ---------------------------------------------
" TexToggleShellEscape
nmap <leader>te <Plug>TexToggleShellEscape
nnoremap <script> <Plug>TexToggleShellEscape <SID>TexToggleShellEscape
nnoremap <SID>TexToggleShellEscape :call <SID>TexToggleShellEscape()<CR>

" TexToggleLatexmk
nmap <leader>tl <Plug>TexToggleLatexmk
nnoremap <script> <Plug>TexToggleLatexmk <SID>TexToggleLatexmk
nnoremap <SID>TexToggleLatexmk :call <SID>TexToggleLatexmk()<CR>


" Set makeprg and errorformat
" ---------------------------------------------
call s:TexSetMakePrg()

" Note: The errorformat used below assumes the tex source file is 
" compiled with pdflatex's -file-line-error option enabled.
setlocal errorformat=%-P**%f
setlocal errorformat+=%-P**\"%f\"

" Match errors
setlocal errorformat+=%E!\ LaTeX\ %trror:\ %m
setlocal errorformat+=%E%f:%l:\ %m
setlocal errorformat+=%E!\ %m

" More info for undefined control sequences
setlocal errorformat+=%Z<argument>\ %m

" More info for some errors
setlocal errorformat+=%Cl.%l\ %m

" Ignore unmatched lines
setlocal errorformat+=%-G%.%#
```
