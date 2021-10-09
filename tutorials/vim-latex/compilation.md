---
title: Compilation | Vim and LaTeX Part 1
---
# Compiling LaTeX Documents in a Vim-Based Workflow

## Contents
<!-- vim-markdown-toc Marked -->

* [Desired functionality](#desired-functionality)
  * [Primary](#primary)
  * [Secondary](#secondary)
* [Configuring `pdflatex` and `latexmk`](#configuring-`pdflatex`-and-`latexmk`)
  * [Implementation: compilation scripts and Vim functions](#implementation:-compilation-scripts-and-vim-functions)
  * [Implementation: error message parsing](#implementation:-error-message-parsing)
  * [Implementation: detecting `minted` and using `--shell-escape`](#implementation:-detecting-`minted`-and-using-`--shell-escape`)
  * [Implementation: toggling compilation with `latexmk`](#implementation:-toggling-compilation-with-`latexmk`)

<!-- vim-markdown-toc -->

## Desired functionality
### Primary
- Vimscript functions for compiling the current `tex` source file using either `pdflatex` or `latexmk`, controlled from within Vim with a keyboard shortcut of my choice. A toggle function for switching between `latexmk` and `pdflatex` compilation is mapped to convenient keyboard shortcut of my choice.

- Relevant error messages are displayed, with line number, in Vim's QuickFix menu. Irrelevant log messages are filtered out as desired using regular expressions and a tool like `grep`

- Compilation runs as an asynchronous background process, and focus stays in Vim throughout compilation (i.e. you don't have to wait until compilation finishes to be able to type.)

### Secondary
- An option for combined "compilation+forward search", which you would use in practice to automatically jump to the last change in the `pdf` document after compilation.


- Context: I occasionally use the `minted` package for including highlighted code blocks in my LaTeX documents. The `minted` package only works if the `tex` source file is compiled with the `--shell-escape` option enabled.

  Thus, I would want:
  1. a script that parses an opened `tex` document for occurrences of the minted package, and automatically enables compilation with `--shell-escape` if `minted` is detected.
  2. a toggle function for turning `--shell-escape` off or on, mapped to convenient keyboard shortcut of your choice.


## Configuring `pdflatex` and `latexmk`
- Current `pdflatex` command
  ```
  pdflatex -file-line-error -halt-on-error -interaction=nonstopmode -output-dir={directory} -synctex=1 
  ```
  See `man pdflatex` for documentation of options. From the documentation:
  - `-file-line-error` prints error  messages in the form `file:line:error`. Reason: to create a predictable error message format for later parsing.

  - `-halt-on-error` exits `pdflatex` immediately if an error is encountered during compilation (instead of attempting to continue compiling the document in spite of the error)

  - `-interaction=nonstopmode` sets `pdflatex`'s run mode to not stop on errors. 

    For official documenation of the possible values of the `interaction` option: run `texdoc texbytopic`, which opens a PDF manual. Look for the chapter `Running TeX` (chapter 32 at the time of writing) and find the subsection `Run modes` (subsection 32.2 at the time of writing), where you will find TeX's run modes explained; the possible values of the `-interaction` option for `pdflatex` have the same effect.

  The idea is to use `-interaction=nonstopmode` *together* with `-halt-on-error`  to halt compilation at the first error and return control to the parent process/program from which `pdflatex` was run.

  - `-output-dir=directory` writes output files in `directory` instead of the current working directory from which `pdflatex` was run. I set `directory` equal to the parent directory of the to-be-compled `tex` file; e.g. to compile `dir1/dir2/myfile.tex` we would have `directory=dir1/dir2`

  - `synctex=1` generates SyncTeX data for the compiled file. Setting the value of the `synctex` option to one saves the `synctex` data in an `gz` archive with the extension `.synctex.gz`. Possible values of the `synctex` argument are documented under `man synctex`

- Current `latexmk` command
  ```
  latexmk -output-directory={directory} -pdf
  ```
  The `latexmk` utility is powerful and well documented; it can be configured to do all kinds of interesting things, e.g. continuous previewing. See `man latexmk` for far more information than is covered here. 
  - `-pdf` tells `latexmk` to compile using `pdflatex`, which creates a `pdf` output file

  - `-output-dir=directory` writes output files in `directory` instead of the current working directory from which `pdflatex` was run. I set `directory` equal to the parent directory of the to-be-compiled `tex` file; e.g. to compile `dir1/dir2/myfile.tex` I would use `directory=dir1/dir2`

- My current `latexmkrc` reads
  ```
  $pdflatex = "pdflatex -file-line-error -halt-on-error -interaction=nonstopmode -synctex=1";
  @generated_exts = (@generated_exts, 'synctex.gz');
  ```

  The `latexmkrc` file is covered in `man latexmkrc` under the section `CONFIGURATION/INITIALIZATION (RC) FILES`. The user `latexmkrc` file can live at `~/.latexmkrc` or `XDG_CONFIG_HOME/latexmk/latexmkrc`, which by default on most UNIX systems will be `~/.config/latexmk/latexmkrc`.

  The `$pdflatex = "..."` line specifies the options `latexmk` should use when compiling with `pdflatex`. Notice these options match the options for vanilla `pdflatex` calls described above.

### Implementation: compilation scripts and Vim functions
Use `:update` to write tex file if needed before compilation

### Implementation: error message parsing

### Implementation: detecting `minted` and using `--shell-escape`

### Implementation: toggling compilation with `latexmk`
