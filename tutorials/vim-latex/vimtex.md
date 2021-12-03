---
title: The vimtex Plugin \| Setting Up Vim for LaTeX Part 2
---
# Getting started with the `vimtex` plugin

## About the series
This is part two in a [five-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents. This article explains how the `vimtex` plugin can appreciably improve your LaTeX experience.

## Contents of this article
<!-- vim-markdown-toc Marked -->

* [Features](#features)
  * [Features](#features)
  * [Disabling things](#disabling-things)
    * [Mappings](#mappings)
    * [Options](#options)
    * [Commands](#commands)
    * [Map definitions](#map-definitions)
    * [Insert mode mappings](#insert-mode-mappings)
    * [Text objects](#text-objects)
    * [Syntax highlighting](#syntax-highlighting)
    * [Other features](#other-features)
  * [My notes](#my-notes)
  * [Disabling features](#disabling-features)
  * [Options](#options)
* [Reference](#reference)
  * [Text objects](#text-objects)
  * [Change and delete stuff](#change-and-delete-stuff)
  * [Toggle-style commands](#toggle-style-commands)
  * [Cool motion commands](#cool-motion-commands)
  * [Commands](#commands)

<!-- vim-markdown-toc -->

## Features

[Screencast](https://github.com/lervag/vimtex#quick-start)

The documentation is over 6000 lines.

VimTeX is a modular LaTeX plugin written in Vimscript

The `vimtex` plugin has excellent documentation.
Nothing you will read here is original.
People just have a hard time reading documentation, and maybe the Markdown syntax helps
And I guess I show references to where to look in the `vimtex` docs, which can be difficult to navigate if you don't know what you're looking for

Use `:VimtexInfo` to see system information and project information (base file name, project root)

### Features
The VimTeX plugin offers more than any one user will reasonably require.

See `:vimtex-features` or equivalently [https://github.com/lervag/vimtex#features](https://github.com/lervag/vimtex#features).

You should read `:help vimtex-requirements`

Among other things:
- LaTeX-specific text objects (environments, commands, etc...)
- Mappings for manipulating commands and environments
- A compilation back-end using `latexmk`
- PDF viewer support
- Document navigation through environments, sections, item lists, table of contents
- Indentation
- Syntax highlighting, including support for common packages
- Snippet-like insert mode mappings

The better approach is "I will cover the following". So:

Motivation I guess is actually quoting the docs

> The documentation is understandably too long for a full read through. It is recommended that new users read or skim the entire introduction, as it should give a clear idea of what VimTeX is and is not. The remaining part of the documentation should then be considered a reference for the various parts of the plugin.

So I guess the purpose here is just to make it easier to skim

**I use**
- LaTeX-specific text objects and associated operator-pending motions
- Context integration for snippets.
- Easy manipulation of surrounding environments and delimiters.
- Syntax highlighting support for common packages: `amsmath`, `minted`

**I don't use**
- Indentation
- Compilation
- PDF integration
- Insert mode mappings

For concealment (e.g. replacing greek letter commands with their unicode equivalents) see [https://castel.dev/post/lecture-notes-1/#vim-and-latex](https://castel.dev/post/lecture-notes-1/#vim-and-latex)

See `:help vimtex-syntax-conceal` and `:help g:vimtex_syntax_conceal` 

### Disabling things
Disable concealment: `g:vimtex_syntax_conceal_disable = 1`

#### Mappings
Documented at `:help vimtex-default-mappings`

All default mappings are documented at `:help vimtex-default-mappings`---scroll down a bit to the table. Every single entry in the table's right-hand side can be jumped to with `C-]`

They are defined in the source code `vimtex/autoload/vimtex.vim` starting around line 125 in the function `s:init_default_mappings()`.

Disable all mappings: `g:vimtex_mappings_enabled = 0`


Possibility: set `g:vimtex_mappings_enabled = 0`, then define mappings manually using `<Plug>` maps.

e.g. from docs
```vim
nmap <space>li <plug>(vimtex-info)
```
You must use `nmap` and not `nnoremap` for `<Plug>` to be remapped!

#### Options
Purpose: this section is where to look if you want to manually disable/enable `vimtex` features or configure features (e.g. the delimiter list, PDF reader, compiler method)

Documentation: `:help vimtex-options`

The documentation is excellent.

#### Commands
Read through `:help vimtex-commands` to see the provided commands.
The documentation is self-explanatory.
Some themes
- Compilation
- PDF reader
- System and plugin status

Note the useful `:VimtexTocOpen` and `:VimtexTocToggle`

#### Map definitions
`:help vimtex-mappings`

This is a reference-like list of `<Plug>` mappings provided by `vimtex`.

Here you can find explanations of many of the mappings in the nice table at `:help vimtex-default-mappings`.

Think of this chapter as "hey, this exists, I can come back here when I want to know what mappings exist and what they do"

#### Insert mode mappings
`:help vimtex-imaps`

- Enabled by default
- Defined in `g:vimtex_imaps_list` and are triggered with the prefix defined in `g:vimtex_imaps_leader`, which is the backtick `` ` `` by default.
- Can be disabled with `g:vimtex_imaps_enabled = 0` and listed with `:VimtexImapsList` (which is only defined if `g:vimtex_imaps_enabled = 1`)

- `vimtex` offers a lot of room for configuration. If you are interested in insert mode mappings, read through `:help vimtex-imaps` in detail. Note that snippets **TODO** reference provide similar functionality.

#### Text objects
See `:help vimtex-text-objects`

Actual definitions are in `vimtex-mappings` and `vimtex-default-mappings`, since `vimtex` text objects are defined as mappings

If you don't know what text objects are, stop what you're doing and learng about them.  As suggested in `:help vimtex-text-objects`, a good place to start would be `:help text-objects` and [*Your problem with Vim is that you don't grok vi*](http://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim/1220118#1220118)

#### Syntax highlighting
See `:help vimtex-syntax`. There is a lot to read here if you're interested, but for most use cases `vimtex`'s syntax features should "just work" out of the box, and you don't need to do anything.

See also `:help vimtex-syntax-packages` and `g:vimtex_syntax_packages` for packages

#### Other features
- Completion at `:help vimtex-completion`

- Folding at `:help vimtex-folding`. You have a lot of power here if you like folding, but you'll probably have to configure some things to make it useful;  `:help vimtex-folding` and the references therein are the place to look

- Indentation `:help vimtex-indent`
  
  This is just a list of references to associated configuration settings

### My notes
- The `vimtex` plugin works fine with a user-defined `tex` filetype plugin. Just be sure not so set `did_ftplugin` in the user-defined plugin or `vimtex` won't load.

  Suggested (find reference): is that place all user-defined `ftplugin` stuff in `nvim/after/ftplugin` instead of `nvim/ftplugin`. Or is this only for things you want to load after Vimtex?

  (Reference?) `vimtex` overrides Vim's internal `ftplugin`, i.e. the one in `$VIMRUNTIME/ftplugin`

-  Disable `vimtex` features by unsetting the `vimtex` variable corresponding to the undesired feature.


- `:help vimtex` (install `vimtex` and run `:helptags`)

- `vimtex` requires UTF-8 character encoding; set `:set encoding=utf8` in your `vimrc` or `init.vim`.

- All `vimtex` features are endabled by default, and disabling features is up to the user.

**TODO** I left off at `:help vimtex-navigation`

### Disabling features
See for example `g:vimtex_mappings_enabled`

Create custom mappings using the provided `<plug>` mappings with
```
map customLHS <Plug>(vimtex-option)
```
Give examples! Possible workflow: if you only want a few mappings, turn off `g:vimtex_mappings_enabled`, then set your desired mappings with the `<plug>` method above.

### Options
See `:help vimtex-options`, it's clear and helpful.

- You can completely disable `vimtex` with `let g:vimtex_enabled = 0`, e.g. in your `vimrc` or in your `ftplugin/tex.vim`?

- Use the `g:vimtex_mappings_enabled` option to control mapping. 1 by default.

  Use `g:vimtex_mappings_disable` to disable specific mappins.

  Use `g:vimtex_imaps_enabled` to control insert mode mappins. 1 by default.

- `g:vimtex_compiler_enabled`. Set to 0 to disable compilation interface.

- `g:vimtex_view_enabled` to control the viewing interface. (**TODO** pdf reader?) 1 by default.

- `g:vimtex_complete_enabled`. Set to 0 to disable Vimtex completion features.

- `g:vimtex_complete_ref` for label completion in custom reference commands.

- See if you like `g:g:vimtex_complete_close_braces`. Off by default.

- Use `g:vimtex_fold_enabled` to control folding. 0 by default.

  See also `vimtex-folding`

  Set `g:vimtex_fold_manual` to 1 for faster folding using the `fold-manual` folding method.

- Use `g:vimtex_indent_enabled` to control indent. 1 by default.

- Use `g:vimtex_syntax_enabled` to control syntax highlighting. 1 by default.



## Reference
Nothing in here is original! Everything can be found in the documentation. It might just be easier to read in markdown instead of plain text.

### Text objects

- `ac` and `ic` for commands
  
- `ad` and `id` for delimiters 

  This one text object covers all of `()`, `[]`, `{}`, etc... *and* their `\left \right`, `\big \big`, etc... variants, which is very nice.
  
- `ae` and `ie` for environments
  
- `a$` and `i$` for inline math
  
- `aP` and `iP` for sections
  
- `am` and `im` for items (i.e. an `\item` in `itemize` and `enumerate` lists).

**Notes**

- These text objects behave like Vim's text objects, explained in `:help text-objects`.
 
- All work in operator-pending and `x` mode.
 
- If needed for custom remapping, `vimtex` text objects are accessed with, for example, `<Plug>(vimtex-ac)` and `<Plug>(vimtex-ic)` for commands, `<Plug>(vimtex-ad)` and `<Plug>(vimtex-id)` for delimiters, and so on...

  **TODO** how to remap e.g. sections to `aS` and `iS`.

### Change and delete stuff
Default mapping is given on left and `<Plug>` mapping on right.

- `dse` `<plug>(vimtex-env-delete)` 

  Deletes  the `\begin` and `\end` declaration of the surrounding environment. Does not change the contents.

- `cse` `<Plug>(vimtex-env-change)` 

  Brings up a prompt to changes the type of surrounding environment; does not change environment contents. 

  Example: `cse align` inside an `equation` environment produces:
  ```
  \begin{equation*}          \begin{align*}
      % contents      -->        % contents 
  \end{equation*}            \end{align*}
  ```

- `ds\$` `<Plug>(vimtex-env-delete-math)`

  Deletes the surrounding `$` delimiters in inline math; does not change math contents.

- `cs\$` `<Plug>(vimtex-env-change-math)`

  Brings up a prompt; the inline math's `$` delimiters are changed to what you entered in the prompt, enclosed in `\begin` and `\end` tags.
  
  Example: `cs$ equation` produces
  ```
  $ 2 + 2 = 4 $ --> \begin{equation} 2 + 2 = 4 \end{equation}
  ```
  

- `dsd` `<Plug>(vimtex-delim-delete)` deletes surrounding delimiters without changing the enclosed content; see also the `ad` and `id` text objects above.

- `csd` `<Plug>(vimtex-delim-change-math)` brings up a prompt to change surrounding delimiters.

  Example: `csd [` inside `( )` delimiters produces
  ```
  ( x + y )  -->  [ x + y ]
  ```
  The `csd` command is "smart"---for example `csd [` inside `\left( \right)` delimiters produces
  ```
  \left( x + y \right)  -->  \left[ x + y \right]
  % as opposed to [ x + y ]
  ```
  
- `dsc` `<Plug>(vimtex-cmd-delete)` deletes the surrounding command. 

  Example: typing `dsc` anywhere inside `\textit{Hello world!}` produces
  ```
  \textit{Hello world!}  -->  Hello world!
  ```
  The `dsc` also recognizes arguments inside square brackets, for example:
  ```
  \sqrt[3]{x + y}  -->  x + y
  ```

- `csc` `<Plug>(vimtex-cmd-change)` brings up a prompt to change the surrounding command.

  Example: typing `csc textbf` anywhere inside `\textit{Hello world!}` produces
  ```
  \textit{Hello world!}  -->  \textbf{Hello world!}
  ```


### Toggle-style commands
- `tsf` `<Plug>(vimtex-cmd-toggle-frac)` toggles between `\frac{a}{b}` and `a/b`

- `tsc` `<Plug>(vimtex-cmd-toggle-star)` and `tse` `<Plug>(vimtex-env-toggle-star)` toggle a starred command or environment. 

  Example: `cse align` inside an `equation` environment produces:
  ```
  \begin{equation}          \begin{equation*}
      % contents      -->        % contents 
  \end{equation}            \end{equation*}

  \ket{\psi}  -->  \ket*{\psi}
  ```

- `tsd` `<Plug>(vimtex-delim-toggle-modifier)` changes between plain and `\left`/`\right` versions of delimiters. 

  Example: `tsd` on the `(x + y)` text below would produce:
  ```
  (x + y)  -->  \left(x + y\right)
  ```
  Delimiters other than `\left \right` (e.g. `\bigl` and `\bigr`) can be added by configuring the `g:vimtex_delim_toggle_mod_list` variable.

  **TODO** my example maybe.

  `tsD` `<Plug>(vimtex-delim-toggle-modifier-reverse)` works like `tsd`, but searches in reverse through the delimiter list. The observed behavior is identical to `tsd` when the delimiter list stored in `g:vimtex_delim_toggle_mod_list` contains only one entry.


### Cool motion commands
All of the following motion commands accept a count and apply to Vim's normal, operator-pending, and visual modes.

- `%` `<plug>(vimtex-%)` when used with the cursor on a delimiter, moves the cursor to the matching delimiter. Works for regular delimiters like `(...)` and `[...]`, but also LaTeX specific delimiters like `\$...\$` and environment `\begin{}` and `\end{}` commands.

- `]]` `<plug>(vimtex-]])` and `[[` `<plug>(vimtex-[[)` jumps to the beginning of the next or current `\section`, `\subsection` or `\subsubsection`, whichever comes first.

  See also `][` and `[]` in `:help <plug>(vimtex-][)` and `:help <plug>(vimtex-[])`

- `]m` `<plug>(vimtex-]m)` and `[m` `<plug>(vimtex-]m)` jumps to the next or previous `\begin` of an environment.

  See also `]M` and `[M` in `:help <plug>(vimtex-]M)` and `:help <plug>(vimtex-[M)`

- `]n` `<plug>(vimtex-]n)` and `[n` `<plug>(vimtex-]n)` jump to the beginning of the next or previous math zone.

  Applies to `\$...\$`, `\[...\]`, and math environments (including from the `amsmath` package) such as `equation`, `align`, etc...

  See also `]N` and `[N` in `:help <plug>(vimtex-]N)` and `:help <plug>(vimtex-[N)`


- `]r` `<plug>(vimtex-]r)` and `[r` `<plug>(vimtex-]r)` jump to the beginning of the next or previous `frame` environment (useful in `beamer` slide show presentations.)

  See also `]R` and `[R` in `:help <plug>(vimtex-]R)` and `:help <plug>(vimtex-[R)`

- `]/` `<plug>(vimtex-]/` and `[/` `<plug>(vimtex-]star`) jumps to the beginning of the next or previous LaTex comment, i.e. text beginning with `%`.

  See also `]*` and `[*` in `:help <plug>(vimtex-]star)` and `:help <plug>(vimtex-[star)`

### Commands
- `vimtex` comes with a few useful status commands that display information about `vimtex`'s current status

- Useful are `:VimtexTocOpen`, `:VimtexTocToggle` (open or toggle a navigable table of contents inside Vim). The table of contents comes with self-explanatory help text.

- See also `:VimtexCountLetters` and `:VimtexCountWords`
