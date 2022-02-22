---
title: The vimtex Plugin \| Setting Up Vim for LaTeX Part 2
---
# First steps with the VimTeX plugin

## About the series
This is part three in a [six-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents.
This article describes the excellent VimTeX plugin, a modern, modular Vim and Neovim plugin that implements a host of useful features for writing LaTeX files.

## Contents of this article
<!-- vim-markdown-toc Marked -->

* [About](#about)
    * [Getting started with VimTeX](#getting-started-with-vimtex)
* [Features](#features)
  * [Mappings](#mappings)
    * [Map definitions](#map-definitions)
  * [Text objects](#text-objects)
    * [Text objects reference](#text-objects-reference)
  * [Configuring mappings](#configuring-mappings)
    * [Disabling default mappings and defining your own](#disabling-default-mappings-and-defining-your-own)
    * [Changing mappings](#changing-mappings)
  * [Doing stuff with mappings](#doing-stuff-with-mappings)
    * [Change and delete stuff](#change-and-delete-stuff)
    * [Toggle-style commands](#toggle-style-commands)
    * [Cool motion commands](#cool-motion-commands)
  * [Insert mode mappings](#insert-mode-mappings)
  * [Options](#options)
    * [Options reference](#options-reference)
  * [Commands](#commands)
    * [A few commands](#a-few-commands)
  * [Syntax highlighting](#syntax-highlighting)
  * [Other features](#other-features)

<!-- vim-markdown-toc -->

<!-- Nothing in this article is particularly original, and comes either directly or indirectly from the VimTeX plugin's excellent documentation. -->

## About
Given VimTeX's superb documentation, what is the point of this guide?
My thinking is that many new users---and I am guilty of this too---quickly become overwhelmed when reading extensive plain-text documentation as a means of learning new software, and perhaps the Markdown syntax, more personal tone, and occasional GIFs in this article will make it easier for new users to digest what VimTeX offers.

My goal is certainly not to replace the VimTeX documentation, which remains essential reading for any serious VimTeX user.
Instead, I hope to quickly bring new users up to a level of comfort at which the documentation becomes useful rather than overwhelming, and to offer pointers as to where in VimTeX documentation to look when interested a given feature.

This guide aims to give an overview of the features VimTeX provides, offers some ideas of how to use these features from the practical perspective of a real-life user, and shows where to look in the documentation for details.

#### Getting started with VimTeX
Install VimTeX like any other Vim plugin using your plugin installation method of choice.

The requirements for using VimTeX are mostly basic stuff: a reasonably up-to-date version of Vim or Neovim, filetype plugins enabled (place the line `:filetype-plugin-on` in your `vimrc`), and UTF8 character encoding enabled.
Naturally, you will need a LaTeX compilation program (e.g. `latexmk` and `pdflatex`) installed on your computer to be able use VimTeX's compilation features.
You need a Vim version compiled with the `+clientserver` feature to use VimTeX's inverse search feature (note that `+clientserver` ships by default with Neovim).
See `:help vimtex-requirements` for details on requirements for using VimTeX.

- The VimTeX plugin works fine with a user-defined `tex` filetype plugin.
  Just be sure not so set `did_ftplugin` in your user-defined plugin or VimTeX won't load.
  VimTeX does overrides Vim's internal `ftplugin`, i.e. the one in `$VIMRUNTIME/ftplugin` (see `:help vimtex-tex-flavor`)

- `:help vimtex` (install VimTeX and run `:helptags`)

- VimTeX requires UTF-8 character encoding; set `:set encoding=utf8` in your `vimrc` or `init.vim`.

- All VimTeX features are enabled by default, and disabling features is up to the user.


## Features
The VimTeX plugin offers more than any one user will probably ever require.
See `:help vimtex-features`, or the equivalent [online version on the VimTeX website](https://github.com/lervag/vimtex#features), for an overview of VimTeX's features.

Among other things, VimTeX offers:
- LaTeX-specific text objects (environments, commands, etc...)
- Mappings for manipulating LaTeX commands and environments
- Motion commands through environments, sections, item lists, matching delimeters, etc...
- Syntax highlighting, including support for common LaTeX packages and detection of math and comment contexts
- Indentation support
- A compilation back-end using `latexmk`
- PDF viewer support
- Snippet-like insert mode mappings

<!-- A few more marginal things -->
<!-- - Document navigation using table of contents -->
<!-- - Word count -->
<!-- - Concealment of LaTeX commands with their Unicode symbol equivalents --> 
<!--   For concealment (e.g. replacing greek letter commands with their unicode equivalents) see [https://castel.dev/post/lecture-notes-1/#vim-and-latex](https://castel.dev/post/lecture-notes-1/#vim-and-latex) -->
<!--   See `:help vimtex-syntax-conceal` and `:help g:vimtex_syntax_conceal` --> 

**I most heavily rely on**
- LaTeX-specific text objects and associated operator-pending motions
- Motion commands through sections, matching delimiters, and environments
- Math context detection for snippet triggers
- LaTeX-specific commands for manipulating environments and delimiters.
- Syntax highlighting support for common packages: `amsmath`, `minted`

### Mappings
VimTeX's default mappings are documented at `:help vimtex-default-mappings`.
If you scroll down a bit, you will reach a three-column list of all mappings defined by VimTeX.
Here is a representative example:
```
---------------------------------------------------------------------
 LHS              RHS                                          MODE
---------------------------------------------------------------------
 <localleader>li  <plug>(vimtex-info)                           `n`
 <localleader>ll  <plug>(vimtex-compile)                        `n`
 csd              <plug>(vimtex-delim-change-math)              `n`
 tse              <plug>(vimtex-env-toggle-star)                `n`
 ac               <plug>(vimtex-ac)                             `xo`
 id               <plug>(vimtex-id)                             `xo`
 ae               <plug>(vimtex-ae)                             `xo`
```
To really understand the table, you should understand how Vim mappings work,
what the `<leader>` and `<localleader>` keys do,
and what the `<plug>` keyword means.
<!-- TODO: link to vimscript -->

Here is how to read the table:
- Each row corresponds to a specific VimTeX feature.
- Each entry in the `LHS` column contains a short key combination (e.g. `dse` or `ad`), which is mapped to the `<Plug>` mapping in the `RHS` column.
  The mapping applies only in the Vim mode specified in the `MODE` column.

- Every single entry in the `RHS` column is described in a dedicated section, which can be jumped to with `C-]`.
  The `RHS` column uses the abbreviations for Vim modes given in `:help map-listing`

  This will take you to an entry in the VimTeX documentation's `COMMANDS` (for `LHS` mappings starting with `<localleader`) or to `MAP DEFINITIONS` section.

#### Map definitions
`:help vimtex-mappings`

This section describes the functionality of the `<Plug>` mappings provided by VimTeX, which are also listed in `:help vimtex-default-mappings`.
I recommend: skim through the table in `:help vimtex-default-mappings`, and then refer to `:help vimtex-mappings` for more information about what a given `<Plug>` mapping does.

Think of this chapter as "hey, this exists, I can come back here when I want to know what mappings exist and what they do"


### Text objects
VimTeX provides a number of LaTeX-specific text objects.
If you don't know what text objects are, stop what you're doing and go learn about them.
As suggested in `:help vimtex-text-objects`, a good place to start would be the Vim documentation section `:help text-objects` and the famous [*Your problem with Vim is that you don't grok vi*](http://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim/1220118#1220118)

VimTeX's text objects are listed in the table in `vimtex-default-mappings` and described in more detail in `vimtex-mappings`.
The section `vimtex-text-objects` gives a general overview of how text objects work, but does not actually list the text objects.

#### Text objects reference
Nothing in here is original! Everything can be found in the documentation.
It might just be easier to read in markdown instead of plain text.

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
 
- If needed for custom remapping, VimTeX text objects are accessed with, for example, `<Plug>(vimtex-ac)` and `<Plug>(vimtex-ic)` for commands, `<Plug>(vimtex-ad)` and `<Plug>(vimtex-id)` for delimiters, and so on...

  **TODO** how to remap e.g. sections to `aS` and `iS`.

For the curious, VimTeX's mappings are defined in the VimTeX source code in `vimtex/autoload/vimtex.vim` starting around line 125 in the function `s:init_default_mappings()`.

### Configuring mappings
#### Disabling default mappings and defining your own
Possibility: set `g:vimtex_mappings_enabled = 0`, then define mappings manually using `<Plug>` maps.

For example, to disable all default mappings besides those shown in the table excerpt above, add the following to your `ftplugin/tex.vim`
```vim
g:vimtex_mappings_enabled = 0

% Manually redefine only the mappings you wish to use
nmap dse <plug>(vimtex-env-delete)
nmap dsc <plug>(vimtex-cmd-delete)

nmap <localleader>li <plug>(vimtex-info)
nmap <localleader>ll <plug>(vimtex-compile)
nmap csd <plug>(vimtex-delim-change-math)
nmap tse <plug>(vimtex-env-toggle-star)

omap ac <plug>(vimtex-ac)
omap id <plug>(vimtex-id)
omap ae <plug>(vimtex-ae)
xmap ac <plug>(vimtex-ac)
xmap id <plug>(vimtex-id)
xmap ae <plug>(vimtex-ae)
```

#### Changing mappings
For example, VimTeX uses `am` and `im` for the item text objects "an item" and "in item" (i.e. items in `itemize` or `enumerate` environments) and `a$` and `i$` for the inline math objects "a math" and "in math".
I prefer to use `am`/`im` for math and `ai`/`ii` for items, which I do with the following code in `ftplugin/tex.vim`:
```vim
omap am <plug>(vimtex-a$)
xmap am <plug>(vimtex-a$)
omap im <plug>(vimtex-i$)
xmap im <plug>(vimtex-i$)

omap ai <plug>(vimtex-am)
xmap ai <plug>(vimtex-am)
omap ii <plug>(vimtex-im)
xmap ii <plug>(vimtex-im)
```
The key is to use VimTeX's default `<plug>` mapping, but use your own, personally-intuitive LHS mapping.

### Doing stuff with mappings
#### Change and delete stuff
Default mapping is given on left and `<Plug>` mapping on right.

- `dse` `<plug>(vimtex-env-delete)` 

  Deletes  the `\begin` and `\end` declaration of the surrounding environment.
  Does not change the contents.

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


#### Toggle-style commands
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

  `tsD` `<Plug>(vimtex-delim-toggle-modifier-reverse)` works like `tsd`, but searches in reverse through the delimiter list.
  The observed behavior is identical to `tsd` when the delimiter list stored in `g:vimtex_delim_toggle_mod_list` contains only one entry.

#### Cool motion commands
All of the following motion commands accept a count and apply to Vim's normal, operator-pending, and visual modes.

- `%` `<plug>(vimtex-%)` when used with the cursor on a delimiter, moves the cursor to the matching delimiter.
  Works for regular delimiters like `(...)` and `[...]`, but also LaTeX specific delimiters like `\$...\$` and environment `\begin{}` and `\end{}` commands.

- `]]` `<plug>(vimtex-]])` and `[[` `<plug>(vimtex-[[)` jumps to the beginning of the next or current `\section`, `\subsection` or `\subsubsection`, whichever comes first.

  See also `][` and `[]` in `:help <plug>(vimtex-][)` and `:help <plug>(vimtex-[])`

- `]m` `<plug>(vimtex-]m)` and `[m` `<plug>(vimtex-]m)` jumps to the next or previous `\begin` of an environment.

  See also `]M` and `[M` in `:help <plug>(vimtex-]M)` and `:help <plug>(vimtex-[M)`

- `]n` `<plug>(vimtex-]n)` and `[n` `<plug>(vimtex-]n)` jump to the beginning of the next or previous math zone.

  Applies to `\$...\$`, `\[...\]`, and math environments (including from the `amsmath` package) such as `equation`, `align`, etc...

  See also `]N` and `[N` in `:help <plug>(vimtex-]N)` and `:help <plug>(vimtex-[N)`


- `]r` `<plug>(vimtex-]r)` and `[r` `<plug>(vimtex-]r)` jump to the beginning of the next or previous `frame` environment (useful in `beamer` slide show presentations.)

  See also `]R` and `[R` in `:help <plug>(vimtex-]R)` and `:help <plug>(vimtex-[R)`

- `]/` `<plug>(vimtex-]/` and `[/` `<plug>(vimtex-]star`) jumps to the beginning of the next or previous LaTeX comment, i.e. text beginning with `%`.

  See also `]*` and `[*` in `:help <plug>(vimtex-]star)` and `:help <plug>(vimtex-[star)`

### Insert mode mappings
VimTeX provides a number of insert mode mappings.
Described in `:help vimtex-imaps`.

- Enabled by default; disable by setting `g:vimtex_imaps_enabled = 0` (TODO link to OPTIONS section)

- Use the command `:VimtexImapsList` (which is only defined if `g:vimtex_imaps_enabled = 1`) to list all active VimTeX-provided insert mode mappings

- Defined in `g:vimtex_imaps_list` and are triggered with the prefix defined in `g:vimtex_imaps_leader`, which is the backtick `` ` `` by default.

- VimTeX offers a lot of room for configuration.
  If you are interested in insert mode mappings, read through `:help vimtex-imaps` in detail.

  Note that snippets, described in an [earlier article in this series]({% link tutorials/vim-latex/ultisnips.md %}), provide similar functionality to VimTeX's insert mode mappings.
  If you use snippets, you can probably disable VimTeX's insert mode mappings.

  From `:help vimtex-UltiSnips`:

  > In recent versions of UltiSnips, one may set normal snippets to trigger
  > automatically, see `:help UltiSnips-autotrigger`. This allows nesting, and is
  > therefore a better approach than using the anonymous snippet function.

### Options
The documentation section `:help vimtex-options` is where to look if you want to manually enable, disable, or otherwise configure VimTeX features (e.g. the delimiter list, PDF reader, compiler method).

VimTeX's options are controlled by setting the values of global Vim variables provided by VimTeX somewhere in your Vim runtimepath before VimTeX loads (a good place would be `ftplugin/tex.vim`).
Disable VimTeX features by unsetting the VimTeX variable corresponding to the undesired feature.
VimTeX then reads the values of any options you set and updates its default behavior accordintly.

TODO: link to Vimscript article section on ftplugin.

Here is a common use case: Enabling or disabling default VimTeX features:
```vim
let g:vimtex_compiler_enabled = 0        " turn off compilation interface
let g:vimtex_view_enabled = 0            " turn off pdf viewer interface
let g:vimtex_indent_enabled = 0          " turn off vimtex indentation
let g:vimtex_mappings_enabled = 0        " disable default mappings
let g:vimtex_imaps_enabled = 0           " disable insert mode mappings (I use UltiSnips)
let g:vimtex_complete_enabled = 0        " turn off completion (not currently used so more efficient to turn off)
let g:vimtex_syntax_conceal_disable = 1  " disable syntax conceal
```
Possible workflow: if you only want a few mappings, set `g:vimtex_mappings_enabled = 0`, then set your desired mappings with the `<plug>` method above.


Changing the delimiter toggle list, using a modified version of the suggestion in `g:vimtex_delim_toggle_mod_list`:
```vim
let g:vimtex_delim_toggle_mod_list = [
  \ ['\left', '\right'],
  \ ['\big', '\big'],
  \]
```
TODO: GIF showing delimiter toggling

Hopefully these two examples give you a feel for usage (you will probably pick up the idea quickly).

#### Options reference
Nothing in here is original! Everything can be found in the documentation.
It might just be easier to read in markdown instead of plain text.

See `:help vimtex-options`, it's clear and helpful.

- You can completely disable VimTeX with `let g:vimtex_enabled = 0`, e.g. in your `vimrc` or in your `ftplugin/tex.vim`?

- Use the `g:vimtex_mappings_enabled` option to control mapping.
  1 by default.

  Use `g:vimtex_mappings_disable` to disable specific mappings.

  Use `g:vimtex_imaps_enabled` to control insert mode mappings.
  1 by default.

- `g:vimtex_compiler_enabled`.
  Set to 0 to disable compilation interface.

- `g:vimtex_view_enabled` to control the viewing interface.
  (**TODO** pdf reader?) 1 by default.

- `g:vimtex_complete_enabled`.
  Set to 0 to disable VimTeX completion features.

- `g:vimtex_complete_ref` for label completion in custom reference commands.

- See if you like `g:g:vimtex_complete_close_braces`.
  Off by default.

- Use `g:vimtex_fold_enabled` to control folding.
  0 by default.

  See also `vimtex-folding`

  Set `g:vimtex_fold_manual` to 1 for faster folding using the `fold-manual` folding method.

- Use `g:vimtex_indent_enabled` to control indent.
  1 by default.

- Use `g:vimtex_syntax_enabled` to control syntax highlighting.
  1 by default.

### Commands
The VimTeX plugin provides a number of user-defined commands, and these are listed and described in the documentation section `:help vimtex-commands`.
<!-- (To understand what is is going on here, it helps to know what user-defined Vim command-line mode commands are---if you feel like going down a rabbit hole see `:help user-commands` and `:help 40.2`.) -->
To commands mostly cover compilation, PDF reader integration, and system and plugin status.
There is nothing I have to say here that the documentation wouldn't say better; I suggest you skim through `:help vimtex-commands` and see if anything strikes your fancy.

#### A few commands
- VimTeX comes with a few useful status commands that display information about VimTeX's current status

- Useful are `:VimtexTocOpen`, `:VimtexTocToggle` (open or toggle a navigable table of contents inside Vim).
  The table of contents comes with self-explanatory help text.

- See also `:VimtexCountLetters` and `:VimtexCountWords`

- Use `:VimtexInfo` to see system information and project information (base file name, project root)

### Syntax highlighting
See `:help vimtex-syntax`.
There is a lot to read here if you're interested, but for most use cases VimTeX's syntax features should "just work" out of the box, and you don't need to do anything.

See also `:help vimtex-syntax-packages` and `g:vimtex_syntax_packages` for packages

TODO: mention math context detection for snippets.

### Other features
- Completion at `:help vimtex-completion`

- Folding at `:help vimtex-folding`.
  You have a lot of power here if you like folding, but you'll probably have to configure some things to make it useful;  `:help vimtex-folding` and the references therein are the place to look

- Indentation `:help vimtex-indent`
  
  This is just a list of references to associated configuration settings
