---
title: The vimtex Plugin \| Setting Up Vim for LaTeX Part 2
---
# First steps with the VimTeX plugin

## About the series
This is part three in a [six-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents.
This article describes the excellent VimTeX plugin, a modern, modular Vim and Neovim plugin that implements a host of useful features for writing LaTeX files.

## Contents of this article
<!-- vim-markdown-toc GFM -->

* [The point of this article](#the-point-of-this-article)
    * [Getting started with VimTeX](#getting-started-with-vimtex)
* [Overview of features](#overview-of-features)
* [How to read VimTeX's documentation of mappings](#how-to-read-vimtexs-documentation-of-mappings)
  * [Map definitions and command descriptions](#map-definitions-and-command-descriptions)
* [Text objects](#text-objects)
  * [Table of VimTeX text objects](#table-of-vimtex-text-objects)
  * [Example: Changing a default text object mapping](#example-changing-a-default-text-object-mapping)
  * [Example: Disabling all default mappings and selectively defining your own](#example-disabling-all-default-mappings-and-selectively-defining-your-own)
* [Doing practical stuff with VimTeX's mappings](#doing-practical-stuff-with-vimtexs-mappings)
  * [Change and delete stuff](#change-and-delete-stuff)
  * [Toggle-style mappings](#toggle-style-mappings)
  * [Cool motion mappings](#cool-motion-mappings)
* [Insert mode mappings](#insert-mode-mappings)
* [Options](#options)
  * [Disabling dfeault features](#disabling-dfeault-features)
  * [Example: Changing the default delimiter toggle list](#example-changing-the-default-delimiter-toggle-list)
* [Commands](#commands)
* [Syntax highlighting](#syntax-highlighting)
* [Other features](#other-features)

<!-- vim-markdown-toc -->

<!-- Nothing in this article is particularly original, and comes either directly or indirectly from the VimTeX plugin's excellent documentation. -->

## The point of this article
This article gives an overview of the features VimTeX provides, offers some ideas of how to use these features from the practical perspective of a real-life user, and shows where to look in the documentation for details.
Given VimTeX's superb documentation, what is the point of this guide?
My reasoning is that many new users---I am often guilty of this too---quickly become overwhelmed when reading extensive plain-text documentation as a means of learning new software, and perhaps the Markdown syntax, highlighted code blocks, and more personal tone in this article will make it easier for new users to digest what VimTeX offers.

My goal is certainly not to replace the VimTeX documentation, which remains essential reading for any serious VimTeX user.
Instead, I hope to quickly bring new users up to a level of comfort at which the documentation becomes useful rather than overwhelming, and to offer pointers as to where in the VimTeX documentation to look when interested a given feature.

#### Getting started with VimTeX
Install VimTeX like any other Vim plugin using your plugin installation method of choice.
The requirements for using VimTeX are mostly straightforward, for example:
- a reasonably up-to-date version of Vim or Neovim
- filetype plugins enabled (place the line `filetype-plugin-on` in your `vimrc`)
- UTF8 character encoding enabled (enabled by default in Neovim; place the line `set encoding=utf-8`in your `vimrc`).

You will need a LaTeX compilation program (e.g. `latexmk` and `pdflatex`) installed on your computer to be able use VimTeX's compilation features.
You also need a Vim version compiled with the `+clientserver` feature to use VimTeX's inverse search feature (note that `+clientserver` ships by default with Neovim).
See `:help vimtex-requirements` for details on requirements for using VimTeX.
<!-- TODO see inverse search article on getting a version of Vim with `+clientserver enabled` -->

As you get started, here are a few things to keep in mind:
- All VimTeX features are enabled by default, and disabling features is up to the user---disabling and configuring features is described in this guide in TODO reference
- The VimTeX documentation, accessed in Vim with `:help vimtex`, is your friend.
  (If for some reason `:help vimtex` comes up empty after a manual installation, you probably haven't generated helptags. Run the Vim command `:helptags ALL` after installing VimTeX to generate the VimTeX documentation; see `:help helptags` for background.)

- As described in `:help vimtex-tex-flavor`, VimTeX overrides Vim's internal `ftplugin`, i.e. the one in `$VIMRUNTIME/ftplugin`. 
  The VimTeX plugin works fine with a user-defined `tex` filetype plugin.
  Just be sure not so set the variable `b:did_ftplugin` in your user-defined plugin or VimTeX won't load.

## Overview of features
The VimTeX plugin offers more than any one user will probably ever require;
you can view a complete list of features at `:help vimtex-features`, or on an [online version on the VimTeX website](https://github.com/lervag/vimtex#features).

This article will cover the following features:
- LaTeX-specific text objects (for environments, commands, etc...) and their associated operator-pending motions
- Motion commands through sections, environments, matching delimiters, item lists, etc...
- LaTeX-specific commands for manipulating environments, commands, and delimiters
- Syntax highlighting, including support for common LaTeX packages
- The potential for math context detection for snippet triggers
- Indentation support
- Snippet-like insert mode mappings
- A compilation back-end using `latexmk`
- PDF viewer support

## How to read VimTeX's documentation of mappings
All of the mappings (i.e. keyboard shortcuts for commands and actions)
provided by VimTeX are nicely described in a three-column list you can find at `:help vimtex-default-mappings`.
You will probably return to this list regularly as you learn to use the plugin.
Here is a representative example of what the list looks like:
```
---------------------------------------------------------------------
 LHS              RHS                                          MODE
---------------------------------------------------------------------
 <localleader>li  <plug>(vimtex-info)                           n
 <localleader>ll  <plug>(vimtex-compile)                        n
 csd              <plug>(vimtex-delim-change-math)              n
 tse              <plug>(vimtex-env-toggle-star)                n
 ac               <plug>(vimtex-ac)                             xo
 id               <plug>(vimtex-id)                             xo
 ae               <plug>(vimtex-ae)                             xo
```
To fully appreciate what's going on, you should understand how Vim mappings work,
what the `<leader>` and `<localleader>` keys do, and what the `<plug>` keyword means.
These topics are described in TODO: link to Vimscript article; you can read that first if you want, but it isn't strictly necessary.

For the present purposes, here is how to interpret the table:
<!-- - Each row corresponds to a specific VimTeX feature (command, action, or text object). -->

- Each entry in the `RHS` column is a Vim `<Plug>` mapping corresponding to a specific VimTeX feature (command, action, or text object).
  For example, `<plug>(vimtex-info)` displays status information about the VimTeX plugin and `<plug>(vimtex-ac)` corresponds to VimTeX's "a command" text object (analogous to Vim's built-in `aw` for "a word" or `ap` for "a paragraph").
  The meaning of every entry in the `RHS` column is described in a dedicated section of the VimTeX documentation, which can be jumped to by hovering over a `RHS` entry and pressing `<CTRL>]`.

- By default, VimTeX maps each entry in the `RHS` column to the short key combination in the `LHS` column.
  You are meant to use the convenient `LHS` shortcut to trigger the action in the `RHS`.
  For example, the key combination `<localleader>li` will display status information about VimTeX, while `ac` is used to access VimTeX's "a command" text object.

- Each mapping works only in a given Vim mode;
  this mode is specified in the `MODE` column using Vim's conventional single-letter abbreviations for mode names.
  For example, `ae <plug>(vimtex-ae) xo` works in Visual (`x`) and Operator-pending (`o`) mode, while `tse <plug>(vimtex-env-toggle-star) n` works in Normal (`n`) mode.
  Vim's mode abbreviations are given in `:help map-listing`.

### Map definitions and command descriptions
The VimTeX documentation sections `COMMANDS` (accessed with `:help vimtex-commands`) and `MAP DEFINITIONS` (accessed with `:help vimtex-mappings`) list and explain the commands and mappings provided by VimTeX.
Remember how pressing `<CTRL>]` on an entry of the `RHS` column described just above takes you to a description of a VimTeX feature?
Those sections live in the `COMMANDS` and `MAP DEFINITIONS` chapters of the VimTeX documentation.

I recommend skimming through the table in `:help vimtex-default-mappings`, then referring to `:help vimtex-commands` or `:help vimtex-mappings` for more information about any mapping that catches your eye.

## Text objects
VimTeX provides a number of LaTeX-specific text objects.
If you don't know what text objects are, stop what you're doing and go learn about them.
As suggested in `:help vimtex-text-objects`, a good place to start would be the Vim documentation section `:help text-objects` and the famous [*Your problem with Vim is that you don't grok vi*](http://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim/1220118#1220118).

VimTeX's text objects are listed in the table in `:help vimtex-default-mappings` and described in more detail in `:help vimtex-mappings`.
The section `:help vimtex-text-objects` gives a general overview of how text objects work, but does not actually list the text objects.

VimTeX's text objects behave exactly like Vim's built-in text objects (which are explained in `:help text-objects`) and work in both operator-pending and visual mode.
For the curious, VimTeX's mappings are defined in the VimTeX source code at the time of writing at around [line 120 of `vimtex/autoload/vimtex.vim`](https://github.com/lervag/vimtex/blob/master/autoload/vimtex.vim#L121) in the function `s:init_default_mappings()`.

### Table of VimTeX text objects
For convenience, here is a table of VimTeX's text-objects, taken directly from `:help vimtex-default-mapping`:

| Mapping | Text object |
| - | - |
| `ac`, `ic` | LaTeX commands |
| `ad`, `id` | Paired delimiters |
| `ae`, `ie` | LaTeX environments |
| `a$`, `i$` | Inline math |
| `aP`, `iP` | Sections |
| `am`, `im` | Items in `itemize` and `enumerate` environments|

The `ad` and `id` delimiter text object covers all of `()`, `[]`, `{}`, etc... *and* their `\left \right`, `\big \big`, etc... variants, which is very nice.

### Example: Changing a default text object mapping
Every default mapping provided by VimTeX can be changed to anything you like.
As an example to get you started with changing default mappings, VimTeX uses `am` and `im` for the item text objects "an item" and "in item" (i.e. items in `itemize` or `enumerate` environments) and `a$` and `i$` for the inline math objects "a math" and "in math".
You might prefer to use (say) `am`/`im` for math and `ai`/`ii` for items, and could implement this change by placing the following code in `ftplugin/tex.vim`:
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
You could then use the `am` and `im` mapping to access the inline math text object, or `ai` an `ii` to access items.
Note that the mappings should be defined in both operator-pending (`omap`) and visual (`xmap`) mode;
the key here is to use your own, personally-intuitive LHS mapping (e.g. `am`) with VimTeX's default `<Plug>` mapping (e.g. `<plug>(vimtex-a$)`).
VimTeX will leave any `<Plug>` mapping you define manually as is, and won't apply the default `LHS` mapping (this behavior is explained in `:help vimtex-default-mappings`).

### Example: Disabling all default mappings and selectively defining your own
VimTeX also makes it easy to disable *all* default mappings, then selectively enable only the mappings you want using the LHS of your choice.
From `:help vimtex-default-mappings`:

> If one prefers, one may disable all the default mappings through the option
> `g:vimtex_mappings_enabled`.  Custom mappings for all desired features must
> then be defined through the listed RHS <plug>-maps or by mapping the available commands.

(You might do this, say, to avoid cluttering the mapping namespace with mappings you won't use.)
To disable all VimTeX default mappings, place `g:vimtex_mappings_enabled = 0` in your `ftplugin/tex.vim`, then manually redefine only those mappings you want using the same mapping syntax shown above in the Example section on [Changing a default text object mapping](#example-changing-a-default-text-object-mapping).
In case that sounds abstract, here is an example to get you started:
```vim
% This code would go in ftplugin/tex.vim

% Disable VimTeX's default mappings
g:vimtex_mappings_enabled = 0

% Manually redefine only the mappings you wish to use
% --------------------------------------------- %
% Some text objects
omap ac <plug>(vimtex-ac)
omap id <plug>(vimtex-id)
omap ae <plug>(vimtex-ae)
xmap ac <plug>(vimtex-ac)
xmap id <plug>(vimtex-id)
xmap ae <plug>(vimtex-ae)

% Some motions
map %  <plug>(vimtex-%)
map ]] <plug>(vimtex-]])
map [[ <plug>(vimtex-[[)

% A few commands
nmap <localleader>li <plug>(vimtex-info)
nmap <localleader>ll <plug>(vimtex-compile)
```
This example, together with the list of default mappings in `:help vimtex-default-mappings`, should be enough to get you on your way towards your own configuration.


## Doing practical stuff with VimTeX's mappings
Following is a summary, with examples, of useful functionality provided by VimTeX that you should know exists.
Again, nothing in this section is particularly original---you can find everything in the VimTeX documentation.
*The shortcut used to access every command listed below can be customized using the same technique as in [Changing a default text object mapping](#example-changing-a-default-text-object-mapping)*---in each case I have included the default shortcut and the corresponding `<Plug>` mapping for convenience.

### Change and delete stuff
You can...

- Delete the `\begin{}` and `\end{}` declaration surrounding a LaTeX environment without changing the environment contents
  using the default shortcut `dse` (delete surrounding environment)
  or the `<Plug>` mapping `<plug>(vimtex-env-delete)`.
  ```tex
  \begin{quote}                     dse
      Using VimTeX is lots of fun!  -->  Using VimTeX is lots of fun!
  \end{quote}
  ```

- Change the type of a LaTeX environment without changing the environment contents
  using `cse` (change surrounding environment)
  or the `<Plug>` mapping: `<Plug>(vimtex-env-change)`.
  For example, one could quickly change and `equation` to an `align` environment as follows:
  ```tex
  \begin{equation*}   cse align   \begin{align*}
      % contents         -->          % contents 
  \end{equation*}                 \end{align*}
  ```

- Delete a LaTeX command while preserving the command's argument(s)
  using `dsc` (delete surrounding command)
  or the `<Plug>` mapping `<Plug>(vimtex-cmd-delete)`.
  For example, typing `dsc` anywhere inside `\textit{Hello world!}` produces:
  ```
                         dsc
  \textit{Hello world!}  -->  Hello world!
  ```
  The `dsc` also recognizes and correctly deletes parameters inside square brackets, for example:
  ```
                   dsc
  \sqrt[3]{x + y}  -->  x + y
  ```

- Delete surrounding `$` delimiters of LaTeX inline math without changing the math contents 
  using `ds$` (delete surrounding math)
  or the `<Plug>` mapping `<Plug>(vimtex-env-delete-math)`.
  ```
                  ds$
  $ 1 + 1 = 2 $   -->  1 + 1 = 2
  ```

- Change inline math `$` delimiters to an environment name, enclosed in `\begin{}` and `\end{}` environment tags,
  using `cs$` (change surrounding math)
  or the `<Plug>` mapping `<Plug>(vimtex-env-change-math)`.
  For example, you could change inline math to an `equation` environment as follows:
  ```tex
                 cs$ equation
  $ 2 + 2 = 4 $       -->       \begin{equation} 2 + 2 = 4 \end{equation}
  ```

- Delete surrounding delimiters (e.g. `()`, `[]`, `{}`, and any of their `\left \right`, `\big \big` variants) without changing the enclosed content
  using `dsd` (delete surrounding delimiter)
  or the `<Plug>` mapping `<Plug>(vimtex-delim-delete)`.
  This command applies to the same delimiters as the `ad` and `id` text objects above.
  ```
           dsd
  (x + y)  -->  x + y

                        dsd
  \left[ X + Y \right]  -->  X + Y
  ```

- Change surrounding delimiters (e.g. `()`, `[]`, `{}`, and any of their `\left \right`, `\big \big` variants) without changing the enclosed content
  using `csd` (change surrounding delimiter)
  or the `<Plug>` mapping `<Plug>(vimtex-delim-change-math)`.
  ```
           csd [
  (x + y)   -->   [x + y]
  ```
  The `csd` command is "smart"---it recognizes and preserves `\left \right`-style modifiers.
  For example, `csd [` inside `\left( \right)` delimiters produces:
  ```
                        csd [
  \left( x + y \right)   -->   \left[ x + y \right]  % as opposed to [ x + y ]
  ```

- Change a LaTeX command while preserving the command's argument(s)
  using `csc` (change surrounding command)
  or the `<Plug>` mapping `<Plug>(vimtex-cmd-change)`.

  Example: typing `csc textbf` anywhere inside `\textit{Hello world!}` produces:
  ```
                         csc textbf
  \textit{Hello world!}     -->      \textbf{Hello world!}
  ```

### Toggle-style mappings
The following commands toggle back and forth between states of various LaTeX environments and commands. 
You can...

- Toggle starred commands and environments using `tsc` `<Plug>(vimtex-cmd-toggle-star)` and `tse` `<Plug>(vimtex-env-toggle-star)`.
  The following example uses `tse` inside an `equation` environment to toggle equation numbering, and `tsc` in a `\section` command to toggle section numbering.
  ```
  \begin{equation}   tse   \begin{equation*}   tse   \begin{equation}
      % contents     -->        % contents     -->       % contents
  \end{equation}           \end{equation*}           \end{equation}

                           tsc                          tsc
  \section*{Introduction}  -->  \section{Introduction}  -->  \section*{Introduction}
  ```

- Change between plain and `\left`/`\right` versions of delimiters using `tsd` `<Plug>(vimtex-delim-toggle-modifier)`.
  The following example uses `tsd` to toggle `\left` and `\right` modifiers around parentheses:
  ```
            tsd                        tsd  
  (x + y)   -->   \left(x + y\right)   -->   (x + y)
  ```
  Delimiters other than `\left \right` (e.g. `\bigl` and `\bigr`) can be added to the list used by `tsd` by configuring the `g:vimtex_delim_toggle_mod_list` variable.

  **TODO** my example maybe.

  `tsD` `<Plug>(vimtex-delim-toggle-modifier-reverse)` works like `tsd`, but searches in reverse through the delimiter list.
  The observed behavior is identical to `tsd` when the delimiter list stored in `g:vimtex_delim_toggle_mod_list` contains only one entry.

- Toggle between inline and `\frac{}{}` versions of fractions using `tsf` `<Plug>(vimtex-cmd-toggle-frac)`.
  Here is an example:
  ```
                tsf         tsf 
  \frac{a}{b}   -->   a/b   -->   \frac{a}{b}
  ```

### Cool motion mappings
All of the following motions accept a count and work in Vim's normal, operator-pending, and visual modes.
You can...

- Move between matching delimiters, inline-math `$` delimiters, and LaTeX environments using `%` and `<plug>(vimtex-%)`.
  ```text
                                   %
  (Some text inside parentheses)  -->  (Some text inside parentheses)
  ‾                                                                 ‾
                  %
  $ 1 + 1 = 2 $  -->  $ 1 + 1 = 2 $
  ‾                               ‾

  \begin{itemize}         \begin{itemize}
  ‾ \item Item 1     %      \item Item 1
    \item Item 2    -->     \item Item 2
    \item Item 3            \item Item 3
  \end{itemize}           \end{itemize}
                                      ‾
  ```
  

- Jump to the beginning of the next `\section`, `\subsection` or `\subsubsection`, whichever comes first, using `]]` and `<plug>(vimtex-]])`.

  Use `[[` and `<plug>(vimtex-[[)` to jump to the beginning of the *current* `\section`, `\subsection` or `\subsubsection` 
  (in practice, this feels like jumping backward---try it yourself and see what I mean),
  and see the similar shortcuts `][` and `[]` in the VimTeX documentation at `:help <plug>(vimtex-][)` and `:help <plug>(vimtex-[])`.

- Jump to the next or previous environment `\begin{}` command using `]m` and`<plug>(vimtex-]m)`, and `[m` and `<plug>(vimtex-]m)`.

  Check the VimTeX documentation for the similar shortcuts `]M` and `[M`, described in `:help <plug>(vimtex-]M)` and `:help <plug>(vimtex-[M)`.

- Jump to the beginning of the next or previous math zone using `]n` and `<plug>(vimtex-]n)`, and `[n` and `<plug>(vimtex-]n)`.
  These motions apply to `$...$`, `\[...\]`, and math environments (including from the `amsmath` package) such as `equation`, `align`, etc..

  Check the VimTeX documentation for the similar shortcuts `]N` and `[N`, described in `:help <plug>(vimtex-]N)` and `:help <plug>(vimtex-[N)`.

- Jump to the beginning of the next or previous `frame` environment (useful in `beamer` slide show presentations) using `]r` and `<plug>(vimtex-]r)`, and `[r` and `<plug>(vimtex-]r)` 

  Check the VimTeX documentation for the similar shortcuts `]R` and `[R`, described in `:help <plug>(vimtex-]R)` and `:help <plug>(vimtex-[R)`.

- Jump to the beginning of the next or previous LaTeX comment (i.e. text beginning with `%`)
  using `]/` and `<plug>(vimtex-]/`, and `[/` `<plug>(vimtex-]star`).

  Check the VimTeX documentation for the similar shortcuts `]*` and `[*`, described in `:help <plug>(vimtex-]star)` and `:help <plug>(vimtex-[star)`.

## Insert mode mappings
VimTeX provides a number of insert mode mappings, which are described in `:help vimtex-imaps`.
VimTeX mappings provide a similar (but less feature-rich) functionality to snippets, described in an [earlier article in this series]({% link tutorials/vim-latex/ultisnips.md %}).
If you use a snippets plugin, you can probably safely disable VimTeX's insert mode mappings without any loss of functionality.
VimTeX's insert mode mappings are enabled by default;
disable them by setting `g:vimtex_imaps_enabled = 0` in `ftplugin/tex.vim` (configuring VimTeX's option variables is covered in more detail in the [Options](#options) section just below).

Although most users following this series will end up disabling VimTeX's insert mode mappings, here are a few things to keep in mind:
- Use the command `:VimtexImapsList` (which is only defined if `g:vimtex_imaps_enabled = 1`) to list all active VimTeX-provided insert mode mappings.
  Insert mode mappings are stored in the global variable in `g:vimtex_imaps_list`.

- VimTeX's insert mode mappings are triggered with the prefix defined in the variable `g:vimtex_imaps_leader`, which is the backtick `` ` `` by default.

- VimTeX offers a lot of room for configuration (e.g. using anonymous expansion functions).
  If you are interested in using its insert mode mappings, read through `:help vimtex-imaps` in detail.

## Options
VimTeX's options are used to manually enable, disable, or otherwise configure VimTeX features (e.g. the delimiter toggle list, the compilation method, the PDF reader),
and are covered in the documentation section `:help vimtex-options`.
VimTeX's options are controlled by setting the values of global Vim variables somewhere in your Vim runtimepath before VimTeX loads (a good place would be `ftplugin/tex.vim`).
You disable VimTeX features by unsetting a Vim variable controlling the undesired feature.
Upon loading, VimTeX reads the values of any option variables you set and updates its default behavior accordingly.

VimTeX's options are documented at `:help vimtex-options`;
the documentation is clear and largely self-explanatory, and you should skim through it to see which options are available.

### Disabling dfeault features
The most common use case for VimTeX options is disabling default VimTeX features.
Here is the general workflow:
1. While skimming through the VimTeX documentation, identify a feature you wish to disable.
   (Most of VimTeX's features are enabled by default, and it is up to the user to disable them.)
1. From the documentation, identify the Vim variable controlling a VimTeX feature; the variable is usually clearly listed in the documentation.
1. Set the appropriate variable value (usually this step amounts to setting an `g:vimtex_*_enabled` variable equal to zero) somewhere in your `ftplugin/tex.vim` file.

  As a concrete example, one could disable VimTeX's indent, insert mode mapping, completion, and syntax concealment features by placing the following code in `ftplugin/tex.vim`:
  ```vim
  " A few examples of disabling default VimTeX features
  let g:vimtex_indent_enabled   = 0      " turn off VimTeX indentation
  let g:vimtex_imaps_enabled    = 0      " disable insert mode mappings (e.g. if you use UltiSnips)
  let g:vimtex_complete_enabled = 0      " turn off completion
  let g:vimtex_syntax_enabled   = 0      " disable syntax conceal
  ```
  These are just examples to get you started;
  in practice, you would of course tweak the settings to your liking after identifying the appropriate variables in the VimTeX documentation.

### Example: Changing the default delimiter toggle list
Here is another real-life example: to add `\big \big` to the delimiter toggle list used by VimTeX's "toggle surrounding delimiter" feature (see the earlier section on [Toggle-style mappings](#toggle-style-mappings)), add the following code to you `ftplugin/tex.vim` file:
```vim
let g:vimtex_delim_toggle_mod_list = [
  \ ['\left', '\right'],
  \ ['\big', '\big'],
  \]
```
The `tsd` `<Plug>(vimtex-delim-toggle-modifier)` mapping will then use both `\left \right` and `\big \big`.
The VimTeX documentation explains configuring the delimiter list in more detail at `:help g:vimtex_delim_toggle_mod_list`.
<!-- TODO: GIF showing delimiter toggling. -->
Hopefully the above two examples give you a feel for setting VimTeX options; the VimTeX documentation should be able to take things from here.

## Commands
The VimTeX plugin provides a number of user-defined commands, and these are listed and described in the documentation section `:help vimtex-commands`.
The commands mostly cover compilation, PDF reader integration, and system and plugin status;
we will return to VimTeX's commands when explaining compilation and PDF reader integration.
There is nothing I have to say about that commands themselves that the documentation wouldn't say better; I suggest you skim through `:help vimtex-commands` and see if anything strikes your fancy.

As a side note, most but not all VimTeX commands can be triggered by default using a shortcut in the `LHS` of the three-column list in `:help vimtex-default-mappings`.
For those commands without a default shortcut mapping, defining one can be as simple as a single line of Vimscript.
Here is an example, which you could place in `ftplugin/tex.vim`, that makes the key combination `<leader>wc` call the VimTeX command `VimtexCountWords`:
```vim
" You might place this code in ftplugin/tex.vim
noremap <leader>wc <cmd>VimtexCountWords<CR>
```
(This mapping uses the `<cmd>` keyword, which is a Vimscript best practice when defining mappings that specifically call commands---see `:help map-cmd` for details.)

## Syntax highlighting
VimTeX provides syntax highlighting that improves on Vim's built-in syntax plugin for LaTeX.
For most use cases VimTeX's syntax features should "just work" out of the box, and you won't need to do anything (if you're interested in details, see `:help vimtex-syntax`).
I can think of three things worth mentioning:
- VimTeX provides correct syntax highlighting for a number of common packages; this means, for example, that the `align` environment provided by the `amsmath` package or code listings using the `minted` package will be correctly highlighted.
  Again, nothing you should need to configure here, but you might appreciate knowing this feature exists.
  See `:help vimtex-syntax-packages` and `g:vimtex_syntax_packages` for details.

- VimTeX's syntax engine is "context-aware" (e.g. can distinguish regular text from LaTeX's math mode).
  This feature makes possible the math-sensitive snippet expansion explained in the [earlier article on snippets]({% link tutorials/vim-latex/ultisnips.md %}).

- VimTeX provides a feature called "syntax-concealment", which replaces various commands, such as math-mode commands for Greek letters, with a shorter Unicode equivalent.
  For example, the `\alpha` command would appear as the character `α` in your terminal.

  I personally do not use syntax concealment; see `:help vimtex-syntax conceal` if you are interested in this feature.
<!--   For concealment (e.g. replacing greek letter commands with their unicode equivalents) see [https://castel.dev/post/lecture-notes-1/#vim-and-latex](https://castel.dev/post/lecture-notes-1/#vim-and-latex) -->

## Other features
Here are a few settings to learn about once you master the basics:
- VimTeX offers completion of citations and reference labels, together with integration with common autocompletion plugins.
  See `:help vimtex-completion` for more information.

- VimTeX's code-folding features are covered at `:help vimtex-folding` and the references therein are the place to look.
  You have a lot of power here if you like code folding, but you'll probably have to configure a few things to make it useful.

- VimTeX provides indentation features that improve on Vim's default indentation plugin for LaTeX.
  You can read about VimTeX's indentation at `:help vimtex-indent`, which is just a list of references to associated configuration settings.
  VimTeX's indentation is enabled by default and should "just work" for most use cases, but there are plenty of configuration option for those who so choose.

- Linting (`:help vimtex-lint`)  and grammar checking (`:help vimtex-grammar`).

- Navigation features `:help vimtex-navigation`.

  See `gf` for locating TeX source files `:help vimtex-includeexpr`

  See `:help vimtex-toc` for the table of contents feature.

- Access to documentation of LaTeX packages.
  
  See `:help vimtex-latexdoc`.

  `:VimtexDocPackage` either takes an argument of uses the word under the cusor for the most relevant documentation.
