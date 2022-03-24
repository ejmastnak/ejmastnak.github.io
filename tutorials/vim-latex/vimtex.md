---
title: A VimTeX Plugin Guide \| Vim and LaTeX Series Part 4

prev-filename: "ftplugin"
prev-display-name: "« 3. Vim's ftplugin system"
next-filename: "compilation"
next-display-name: "5. Compilation »"

---

{% include vim-latex-navbar.html %}

# 4. Getting started with the VimTeX plugin
This is part four in a [seven-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents.
This article describes the excellent [VimTeX plugin](https://github.com/lervag/vimtex/), a modular Vim and Neovim plugin that implements a host of useful features for writing LaTeX files.

## Contents of this article
<!-- vim-markdown-toc GFM -->

* [The point of this article](#the-point-of-this-article)
    * [Getting started with VimTeX](#getting-started-with-vimtex)
    * [Some things to keep in mind](#some-things-to-keep-in-mind)
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
  * [Motion mappings](#motion-mappings)
* [Insert mode mappings](#insert-mode-mappings)
* [Options](#options)
  * [Example: Disabling default features](#example-disabling-default-features)
  * [Example: Changing the default delimiter toggle list](#example-changing-the-default-delimiter-toggle-list)
* [Commands](#commands)
* [Syntax highlighting](#syntax-highlighting)
* [Other features](#other-features)

<!-- vim-markdown-toc -->

## The point of this article
This article gives an overview of the features VimTeX provides, offers some ideas of how to use these features from the practical perspective of a real-life user, and shows where to look in the documentation for details.
Given VimTeX's superb documentation, what is the point of this guide?
My reasoning is that many new users---I am often guilty of this too---quickly become overwhelmed when reading extensive plain-text documentation as a means of learning new software, and perhaps the Markdown syntax, highlighted code blocks, and more personal tone in this article will make it easier for new users to digest what VimTeX offers.

My goal is certainly not to replace the VimTeX documentation, which remains essential reading for any serious VimTeX user.
Instead, I hope to quickly bring new users up to a level of comfort at which the documentation becomes useful rather than overwhelming, and to offer pointers as to where in the VimTeX documentation to look when interested about a given feature.

**Background knowledge:** this article will make regular references to the file `ftplugin/tex.vim`, which is used as part of Vim's filetype plugin system to implement LaTeX-specific Vim configuration.
To get the most out of this article, you should understand the purpose of the `ftplugin/tex.vim` file and have a basic understanding of Vim's filetype plugin system.
In case you are just dropping in now, these topics were covered in the [previous article in this series]({% link tutorials/vim-latex/ftplugin.md %}), which you should read now if you haven't already.

#### Getting started with VimTeX
Install VimTeX like any other Vim plugin using your plugin installation method of choice.
The requirements for using VimTeX are mostly straightforward, for example:
- a reasonably up-to-date version of Vim or Neovim
- filetype plugins enabled (place the line `filetype-plugin-on` in your `vimrc` or `init.vim`)
- UTF8 character encoding enabled (enabled by default in Neovim; place the line `set encoding=utf-8`in your `vimrc`).

See `:help vimtex-requirements` for details on requirements for using VimTeX.

Note that you will need a LaTeX compilation program (e.g. `latexmk` and `pdflatex`) installed on your computer to be able use VimTeX's compilation features.
You also need a Vim version compiled with the `+clientserver` feature to use VimTeX's inverse search feature with PDF readers (note that `+clientserver` ships by default with Neovim).
I cover compilation and setting up a PDF reader in detail in the [next]({% link tutorials/vim-latex/compilation.md %}) [two]({% link tutorials/vim-latex/pdf-reader.md %}) articles in this series, so you can postpone these requirements until then.

#### Some things to keep in mind
As you get started with the VimTeX plugin, here are a few things to keep in mind:

- Assuming you have installed VimTeX and meet the above-described requirements, you can check that VimTeX has loaded by opening a file with the `.tex` extension and issuing the command `:VimtexInfo`.
  If this opens a window with various system status information, VimTeX has loaded and you're good to go.
  If the command `:VimtexInfo` returns `E492: Not an editor command: VimtexInfo`, VimTeX has not loaded.
  Double-check that VimTeX is installed and that you meet the plugin's above-described requirements.
  If that fails and VimTeX still doesn't load, scroll down four bullet points and see if the long bullet point about overriding VimTeX with a user-defined filetype plugin applies to you.
  If *that* fails, turn to the Internet for help.

- The VimTeX documentation, accessed in Vim with `:help vimtex`, is your friend.
  (If for some reason `:help vimtex` comes up empty after a manual installation, you probably haven't generated helptags. Run the Vim command `:helptags ALL` after installing VimTeX to generate the VimTeX documentation; see `:help helptags` for background.)

- All VimTeX features are enabled by default, and disabling features is up to the user---disabling and configuring features is described later in this article in the section on [VimTeX's options](#options).

- As described in `:help vimtex-tex-flavor`, VimTeX overrides Vim's internal `ftplugin`, i.e. the one in `$VIMRUNTIME/ftplugin`. 
  
- I first want to note: if you are new to Vim, the VimTeX plugin loads without any problem, and you have no idea what I'm talking about in this bullet point, don't worry and skip it.
  The point is to make sure that VimTeX loads, and if VimTeX loads for you without issues, you're good to go.

  Warning aside, here is the potential problem: the VimTeX plugin respects (and will not override) a user-defined `tex` filetype plugin.
  You must be careful though---there is a risk of *your* `tex` filetype plugin overriding VimTeX!
  Namely, VimTeX will not load if you set the Vimscript variable `let b:did_ftplugin = 1` in your user-defined `tex` plugin, for example with the common boilerplate code
  ```vim
  " This common piece of boilerplate code will prevent VimTeX from loading
  " if placed in a user-defined LaTeX filetype plugin in `~/.vim/ftplugin/tex.vim`.
	if exists("b:did_ftplugin")
	  finish
	endif
	let b:did_ftplugin = 1
  " Using a variable like `b:did_my_ftplugin` will solve the problem.
  ```
  Here is the problem: VimTeX *also* uses the variable `b:did_ftplugin` to avoid loading twice in the same Vim buffer.
  User-defined filetype plugins load before VimTeX, so if *you* set `let b:did_ftplugin = 1`, then VimTeX will see `b:did_ftplugin = 1` and not load (you can see this behavior for yourself in the VimTeX source code in the file `vimtex/ftplugin/tex.vim`).
  If you want to use both VimTeX and your own `tex` filetype plugin and currently have `let b:did_ftplugin = 1` in your own plugin, just change to a variable name like `b:did_my_ftplugin` instead, which won't conflict with VimTeX's use of `b:did_ftplugin`.

  (The `let b:did_ftplugin = 1` business is a standard safety mechanism described in the Vim documentation at `:help ftplugin` that gives the user control over loading filetype plugins.)
  
## Overview of features
The VimTeX plugin offers more than any one user will probably ever require;
you can view a complete list of features at `:help vimtex-features`, or see an [online version on the VimTeX GitHub page](https://github.com/lervag/vimtex#features).

This article will cover the following features:
- LaTeX-specific text objects (for environments, commands, etc.) and their associated operator-pending motions
- Motion commands through sections, environments, matching delimiters, item lists, etc.
- LaTeX-specific commands for manipulating environments, commands, and delimiters
- Syntax highlighting, including support for common LaTeX packages
- The potential for math context detection for snippet triggers
- Indentation support
- Snippet-like insert mode mappings

VimTeX also provides a compilation interface and PDF viewer support, which I have left out of this article and describe in two [dedicated]({% link tutorials/vim-latex/compilation.md %}) [articles]({% link tutorials/vim-latex/pdf-reader.md %}) later in the series.

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
To have a clear mental image of what's going on here, you should understand how Vim mappings work,
what the `<leader>` and `<localleader>` keys do, and what the `<plug>` keyword means.
If you want to learn about these topics now, take a detour and read through [the Vimscript article]({% link tutorials/vim-latex/vimscript.md %}), which is the final article in this series.

For the present purposes, here is how to interpret the table:

- Each entry in the middle, `RHS`, column is a Vim `<Plug>` mapping corresponding to a specific VimTeX feature (e.g. a command, action, or text object).
  For example, `<plug>(vimtex-info)` displays status information about the VimTeX plugin and `<plug>(vimtex-ac)` corresponds to VimTeX's "a command" text object (analogous to Vim's built-in `aw` for "a word" or `ap` for "a paragraph").
  The meaning of every entry in the `RHS` column is described in a dedicated section of the VimTeX documentation, which can be jumped to by hovering over a `RHS` entry and pressing `<Ctrl>]`.

- By default, VimTeX maps each entry in the `RHS` column to the short key combination in the `LHS` column.
  You are meant to use the convenient `LHS` shortcut to trigger the action in the `RHS`.
  For example, the key combination `<localleader>li` will display status information about VimTeX, while `ac` is the shortcut for VimTeX's "a command" text object.

- Each mapping works only in a given Vim mode;
  this mode is specified in the `MODE` column using Vim's conventional single-letter abbreviations for mode names.
  For example, `ae <plug>(vimtex-ae) xo` works in visual (`x`) and operator-pending (`o`) mode, while `tse <plug>(vimtex-env-toggle-star) n` works in normal (`n`) mode.
  For more information about map modes and key mappings, see the Vim documentation section `:help map-listing` and the [Vimscript article]({% link tutorials/vim-latex/vimscript.md %}) later in this series.

### Map definitions and command descriptions
The VimTeX documentation sections `COMMANDS` (accessed with `:help vimtex-commands`) and `MAP DEFINITIONS` (accessed with `:help vimtex-mappings`) list and explain the commands and mappings provided by VimTeX.
I recommend skimming through the table in `:help vimtex-default-mappings`, then referring to `:help vimtex-commands` or `:help vimtex-mappings` for more information about any mapping that catches your eye.

## Text objects
VimTeX provides a number of LaTeX-specific text objects.
If you don't know what text objects are, stop what you're doing and go learn about them.
As suggested in `:help vimtex-text-objects`, a good place to start would be the Vim documentation section `:help text-objects` and the famous Stack Overflow answer [*Your problem with Vim is that you don't grok vi*](http://stackoverflow.com/questions/1218390/what-is-your-most-productive-shortcut-with-vim/1220118#1220118).

VimTeX's text objects are listed in the table in `:help vimtex-default-mappings` and described in more detail in `:help vimtex-mappings`;
the text objects behave exactly like Vim's built-in text objects (which are explained in `:help text-objects`) and work in both operator-pending and visual mode.

The section `:help vimtex-text-objects` gives a general overview of how text objects work, but does not actually list the text objects.
For the curious, VimTeX's mappings, including text objects, are defined in the VimTeX source code at around [line 120 of `vimtex/autoload/vimtex.vim`](https://github.com/lervag/vimtex/blob/master/autoload/vimtex.vim#L121) in the function `s:init_default_mappings()` at the time of writing.

### Table of VimTeX text objects
For convenience, here is a table of VimTeX's text-objects, taken directly from `:help vimtex-default-mappings`:

| Mapping | Text object |
| - | - |
| `ac`, `ic` | LaTeX commands |
| `ad`, `id` | Paired delimiters |
| `ae`, `ie` | LaTeX environments |
| `a$`, `i$` | Inline math |
| `aP`, `iP` | Sections |
| `am`, `im` | Items in `itemize` and `enumerate` environments|

The `ad` and `id` delimiter text object covers all of `()`, `[]`, `{}`, etc. *and* their `\left \right`, `\big \big`, etc. variants, which is very nice.

Here is a visual mode example of the delimeter and environment text objects:

<image src="/assets/images/vim-latex/vimtex/text-objects.gif" alt="VimTeX's text objects"  /> 

### Example: Changing a default text object mapping
Every default mapping provided by VimTeX can be changed to anything you like.
As an example to get you started with changing default mappings, VimTeX uses `am` and `im` for the item text objects "an item" and "in item" (i.e. items in `itemize` or `enumerate` environments) and `a$` and `i$` for the inline math objects "a math" and "in math".
You might prefer to use (say) `am`/`im` for math and `ai`/`ii` for items, and could implement this change by placing the following code in `ftplugin/tex.vim`:
```vim
" Use `am` and `im` for the inline math text object
omap am <plug>(vimtex-a$)
xmap am <plug>(vimtex-a$)
omap im <plug>(vimtex-i$)
xmap im <plug>(vimtex-i$)

" Use `ai` and `ii` for the item text object
omap ai <plug>(vimtex-am)
xmap ai <plug>(vimtex-am)
omap ii <plug>(vimtex-im)
xmap ii <plug>(vimtex-im)
```
You could then use the `am` and `im` mapping to access the inline math text object, or `ai` an `ii` to access items.
Note that the mappings should be defined in both operator-pending (`omap`) and visual (`xmap`) mode.

The key when redefining default mappings is to use your own, personally-intuitive LHS mapping (e.g. `am`) with VimTeX's default `<Plug>` mapping (e.g. `<plug>(vimtex-a$)`).
VimTeX will leave any `<Plug>` mapping you define manually as is, and won't apply the default `LHS` mapping (this behavior is explained in `:help vimtex-default-mappings`).

### Example: Disabling all default mappings and selectively defining your own
VimTeX also makes it easy to disable *all* default mappings, then selectively enable only the mappings you want, using the LHS of your choice.
From `:help vimtex-default-mappings`:

> If one prefers, one may disable all the default mappings through the option
> `g:vimtex_mappings_enabled`.  Custom mappings for all desired features must
> then be defined through the listed RHS <plug>-maps or by mapping the available commands.

(You might do this, say, to avoid cluttering the mapping namespace with mappings you won't use.)
To disable all VimTeX default mappings, place `g:vimtex_mappings_enabled = 0` in your `ftplugin/tex.vim`, then manually redefine only those mappings you want using the same mapping syntax shown above in the Example section on [Changing a default text object mapping](#example-changing-a-default-text-object-mapping).
In case that sounds abstract, here is an example to get you started:
```vim
" An example of disabling all default VimTeX mappings, then selectively
" defining your own. This code would go in ftplugin/tex.vim.

" Disable VimTeX's default mappings
g:vimtex_mappings_enabled = 0

" Manually redefine only the mappings you wish to use
" --------------------------------------------- "
" Some text objects
omap ac <plug>(vimtex-ac)
omap id <plug>(vimtex-id)
omap ae <plug>(vimtex-ae)
xmap ac <plug>(vimtex-ac)
xmap id <plug>(vimtex-id)
xmap ae <plug>(vimtex-ae)

" Some motions
map %  <plug>(vimtex-%)
map ]] <plug>(vimtex-]])
map [[ <plug>(vimtex-[[)

" A few commands
nmap <localleader>li <plug>(vimtex-info)
nmap <localleader>ll <plug>(vimtex-compile)
```
This example, together with the list of default mappings in `:help vimtex-default-mappings`, should be enough to get you on your way towards your own configuration.


## Doing practical stuff with VimTeX's mappings
Following is a summary, with examples, of useful functionality provided by VimTeX that you should know exists.
Again, nothing in this section is particularly original---you can find everything in the VimTeX documentation.

Note that the shortcut used to access every command listed below can be customized using the same technique as in [Changing a default text object mapping](#example-changing-a-default-text-object-mapping)---in each case I have included the default shortcut and the corresponding `<Plug>` mapping for convenience.

### Change and delete stuff
You can...

- Delete the `\begin{}` and `\end{}` declaration surrounding a LaTeX environment without changing the environment contents
  using the default shortcut `dse` (delete surrounding environment)
  or the `<Plug>` mapping `<plug>(vimtex-env-delete)`.
  For example, using `dse` in a `quote` environment produces:
  ```tex
  \begin{quote}                     dse
  Using VimTeX is lots of fun!  -->  Using VimTeX is lots of fun!
  \end{quote}
  ```
  <image src="/assets/images/vim-latex/vimtex/dse.gif" alt="Deleting a surrounding quote environment with dse"  /> 

- Change the type of a LaTeX environment without changing the environment contents
  using `cse` (change surrounding environment)
  or the `<Plug>` mapping `<Plug>(vimtex-env-change)`.
  For example, one could quickly change an `equation` to an `align` environment as follows:
  ```tex
  \begin{equation*}   cse align   \begin{align*}
      % contents         -->          % contents 
  \end{equation*}                 \end{align*}
  ```
  <image src="/assets/images/vim-latex/vimtex/cse.gif" alt="Changing equation to align with dse"  /> 

- Delete a LaTeX command while preserving the command's argument(s)
  using `dsc` (delete surrounding command)
  or the `<Plug>` mapping `<Plug>(vimtex-cmd-delete)`.
  For example, typing `dsc` anywhere inside `\textit{Hello, dsc!}` produces:
  ```tex
                         dsc
  \textit{Hello, dsc!}  -->  Hello, dsc!
  ```
  The `dsc` also recognizes and correctly deletes parameters inside square brackets, for example:
  ```tex
                   dsc
  \sqrt[n]{a}  -->  a
  ```
  Here are the above two examples in action:
  <image src="/assets/images/vim-latex/vimtex/dsc.gif" alt="Demonstrating the dsc action"  /> 

- Delete surrounding `$` delimiters of LaTeX inline math without changing the math contents 
  using `ds$` (delete surrounding math)
  or the `<Plug>` mapping `<Plug>(vimtex-env-delete-math)`.
  Here is an example:
  ```tex
                  ds$
  $ 1 + 1 = 2 $   -->  1 + 1 = 2
  ```
  Conveniently, the `ds$` works with all math environments, not just inline math.
  <image src="/assets/images/vim-latex/vimtex/dsm.gif" alt="Demonstrating the dsm action"  /> 

- Change inline math `$` delimiters to an environment name, enclosed in `\begin{}` and `\end{}` environment tags,
  using `cs$` (change surrounding math)
  or the `<Plug>` mapping `<Plug>(vimtex-env-change-math)`.
  For example, you could change inline math to an `equation` environment as follows:
  ```tex
                 cs$ equation
  $ 1 + 1 = 2 $       -->       \begin{equation}
                                    1 + 1 = 2 
                                \end{equation}
  ```
  Note the correct indentation inside the `equation` environment!
  <image src="/assets/images/vim-latex/vimtex/csm.gif" alt="Changing inline math to an equaiton with the csm action"  /> 

- Delete surrounding delimiters (e.g. `()`, `[]`, `{}`, and any of their `\left \right`, `\big \big` variants) without changing the enclosed content
  using `dsd` (delete surrounding delimiter)
  or the `<Plug>` mapping `<Plug>(vimtex-delim-delete)`.
  This command applies to the same delimiters as the `ad` and `id` text objects above.
  Here are two examples of deleting delimiters with `dsd`:
  ```tex
           dsd
  (x + y)  -->  x + y

                      dsd
  \left(X + Y\right)  -->  X + Y
  ```
  Here are the above two examples in action:
  <image src="/assets/images/vim-latex/vimtex/dsd.gif" alt="Demonstrating the dsd action"  /> 

- Change surrounding delimiters (e.g. `()`, `[]`, `{}`, and any of their `\left \right`, `\big \big` variants) without changing the enclosed content
  using `csd` (change surrounding delimiter)
  or the `<Plug>` mapping `<Plug>(vimtex-delim-change-math)`.
  For instance, you could change parentheses to square brackets as follows:
  ```tex
           csd [
  (a + b)   -->   [b + b]
  ```
  The `csd` command is "smart"---it recognizes and preserves `\left \right`-style modifiers.
  For example, `csd [` inside `\left( \right)` delimiters produces:
  ```tex
                        csd [
  \left(A + B\right)   -->   \left[A + B\right]  % as opposed to [A + B]
  ```
  Here are the above two examples in a GIF:
  <image src="/assets/images/vim-latex/vimtex/csd.gif" alt="Demonstrating the csd action"  /> 

- Change a LaTeX command while preserving the command's argument(s)
  using `csc` (change surrounding command)
  or the `<Plug>` mapping `<Plug>(vimtex-cmd-change)`.
  As an example, you could change italic text to boldface text as follows:
  ```
                            csc textit
  \textbf{Make me italic!}     -->      \textit{Make me italic!}
  ```
  <image src="/assets/images/vim-latex/vimtex/csc.gif" alt="Demonstrating the csc action"  /> 

### Toggle-style mappings
The following commands toggle back and forth between states of various LaTeX environments and commands. 
You can...

- Toggle starred commands and environments using `tsc` `<Plug>(vimtex-cmd-toggle-star)` and `tse` `<Plug>(vimtex-env-toggle-star)`.
  The following example uses `tse` inside an `equation` environment to toggle equation numbering, and `tsc` in a `\section` command to toggle section numbering:
  ```tex
                      tsc                       tsc
  \section{Toggling}  -->  \section*{Toggling}  -->  \section{Toggling}

  \begin{equation}   tse   \begin{equation*}   tse   \begin{equation}
      x + y = z      -->        x + y = z      -->       x + y = z
  \end{equation}           \end{equation*}           \end{equation}
  ```
  Here are the above two examples in a GIF:
  <image src="/assets/images/vim-latex/vimtex/tsc-tse.gif" alt="Demonstrating the tsc and tse actions"  /> 

- Change between plain and `\left`/`\right` versions of delimiters using `tsd` `<Plug>(vimtex-delim-toggle-modifier)`.
  The following example uses `tsd` to toggle `\left` and `\right` modifiers around parentheses:
  ```tex
            tsd                        tsd  
  (x + y)   -->   \left(x + y\right)   -->   (x + y)
  ```
  Delimiters other than `\left \right` (e.g. `\big`, `\Big`, etc.) can be added to the list used by `tsd` by configuring the `g:vimtex_delim_toggle_mod_list` variable; for a concrete example of how to do this, scroll down to the section [Example: Changing the default delimiter toggle list](#example-changing-the-default-delimiter-toggle-list).
  Here is an example with both `\left \right` and `\big`:
  <image src="/assets/images/vim-latex/vimtex/tsd.gif" alt="Using the tsd shortcut"  /> 

  `tsD` `<Plug>(vimtex-delim-toggle-modifier-reverse)` works like `tsd`, but searches in reverse through the delimiter list.
  The observed behavior is identical to `tsd` when the delimiter list stored in `g:vimtex_delim_toggle_mod_list` contains only one entry.

- Toggle between inline and `\frac{}{}` versions of fractions using `tsf` `<Plug>(vimtex-cmd-toggle-frac)`.
  Here is an example:
  ```
                tsf         tsf 
  \frac{a}{b}   -->   a/b   -->   \frac{a}{b}
  ```
  <image src="/assets/images/vim-latex/vimtex/tsf.gif" alt="Demonstrating the tsf shortcut"  /> 

### Motion mappings
All of the following motions accept a count and work in Vim's normal, operator-pending, and visual modes.
You can...

- Move between matching delimiters, inline-math `$` delimiters, and LaTeX environments using `%` and `<plug>(vimtex-%)`.
  Here are some examples:
  <image src="/assets/images/vim-latex/vimtex/move-matching.gif" alt="Demonstrating the VimTeX % motion command"  /> 
  
- Jump to the beginning of the next `\section`, `\subsection` or `\subsubsection`, whichever comes first, using `]]` and `<plug>(vimtex-]])`.

  Use `[[` and `<plug>(vimtex-[[)` to jump to the beginning of the *current* `\section`, `\subsection` or `\subsubsection` 
  (in practice, this feels like jumping backward---try it yourself and see what I mean),
  and see the similar shortcuts `][` and `[]` in the VimTeX documentation at `:help <plug>(vimtex-][)` and `:help <plug>(vimtex-[])`.

  Here are the `[[` and `]]` motions in action:
  <image src="/assets/images/vim-latex/vimtex/move-section.gif" alt="Demonstrating the VimTeX section motion command"  /> 

- Jump to the next or previous environment `\begin{}` command using `]m` and`<plug>(vimtex-]m)`, and `[m` and `<plug>(vimtex-]m)`.

  Check the VimTeX documentation for the similar shortcuts `]M` and `[M`, described in `:help <plug>(vimtex-]M)` and `:help <plug>(vimtex-[M)`.
  
  Here are some of the environment motion commands in action:

  <image src="/assets/images/vim-latex/vimtex/move-environment.gif" alt="Demonstrating the VimTeX environment motion commands"  /> 

- Jump to the beginning of the next or previous math zone using `]n` and `<plug>(vimtex-]n)`, and `[n` and `<plug>(vimtex-]n)`.
  These motions apply to `$...$`, `\[...\]`, and math environments (including from the `amsmath` package) such as `equation`, `align`, etc.

  Check the VimTeX documentation for the similar shortcuts `]N` and `[N`, described in `:help <plug>(vimtex-]N)` and `:help <plug>(vimtex-[N)`.

  Here are some examples of moving through math zones:

  <image src="/assets/images/vim-latex/vimtex/move-math.gif" alt="Demonstrating the VimTeX math motion commands"  /> 

- Jump to the beginning of the next or previous `frame` environment (useful in `beamer` slide show presentations) using `]r` and `<plug>(vimtex-]r)`, and `[r` and `<plug>(vimtex-]r)` .

  Check the VimTeX documentation for the similar shortcuts `]R` and `[R`, described in `:help <plug>(vimtex-]R)` and `:help <plug>(vimtex-[R)`.
  
  Here are some of the frame motions in action:
  <image src="/assets/images/vim-latex/vimtex/move-frame.gif" alt="Demonstrating the VimTeX frame motion commands"  /> 

<!-- **TODO:** I did not get this motion ot work in testing! -->
<!-- - Jump to the beginning of the next or previous LaTeX comment (i.e. text beginning with `%`) -->
<!--   using `]/` and `<plug>(vimtex-]/`, and `[/` `<plug>(vimtex-]star`). -->

  <!-- Check the VimTeX documentation for the similar shortcuts `]*` and `[*`, described in `:help <plug>(vimtex-]star)` and `:help <plug>(vimtex-[star)`. -->

## Insert mode mappings
VimTeX provides a number of insert mode mappings, which are described in `:help vimtex-imaps`.
VimTeX mappings provide a similar (but less feature-rich) functionality to snippets, described in an [earlier article in this series]({% link tutorials/vim-latex/ultisnips.md %}).
If you use a snippets plugin, you can probably safely disable VimTeX's insert mode mappings without any loss of functionality.
VimTeX's insert mode mappings are enabled by default;
disable them by setting `g:vimtex_imaps_enabled = 0` in your `ftplugin/tex.vim` file (configuring VimTeX's option variables is covered in more detail in the [Options](#options) section just below).

Although most users following this series will probably end up disabling VimTeX's insert mode mappings, here are a few things to keep in mind:
- Use the command `:VimtexImapsList` (which is only defined if insert mode mappings are enabled) to list all active VimTeX-provided insert mode mappings.

  Insert mode mappings are stored in the global variable in `g:vimtex_imaps_list`.

- VimTeX's insert mode mappings are triggered with the prefix defined in the variable `g:vimtex_imaps_leader`, which is the backtick `` ` `` by default.

- VimTeX offers a lot of room for configuration (e.g. using anonymous expansion functions).
  If you are interested in using its insert mode mappings, read through `:help vimtex-imaps` in detail.

## Options
VimTeX's options are used to manually enable, disable, or otherwise configure VimTeX features (e.g. the delimiter toggle list, the compilation method, the PDF reader, etc.),
and are covered in the documentation section `:help vimtex-options`.
VimTeX's options are controlled by setting the values of global Vim variables somewhere in your Vim `runtimepath` before VimTeX loads (a good place would be `ftplugin/tex.vim`).
You disable VimTeX features by un-setting a Vim variable controlling the undesired feature.
Upon loading, VimTeX reads the values of any option variables you set manually and updates its default behavior accordingly.

VimTeX's options are documented at `:help vimtex-options`;
the documentation is clear and largely self-explanatory, and you should skim through it to see which options are available.

### Example: Disabling default features
The most common use case for VimTeX options is disabling default VimTeX features.
Here is the general workflow:
1. While skimming through the VimTeX documentation, identify a feature you wish to disable.
   (Most of VimTeX's features are enabled by default, and it is up to the user to disable them.)
1. From the documentation, identify the Vim variable controlling a VimTeX feature; the variable is usually clearly listed in the documentation.
1. Set the appropriate variable value (usually this step amounts to setting a `g:vimtex_*_enabled` variable equal to zero) somewhere in your `ftplugin/tex.vim` file.

  As a concrete example, one could disable VimTeX's indent, insert mode mapping, completion, and syntax concealment features by placing the following code in `ftplugin/tex.vim`:
  ```vim
  " A few examples of disabling default VimTeX features.
  " The code would go in `ftplugin/tex.vim`.
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
" Example: adding `\big` to VimTeX's delimiter toggle list
let g:vimtex_delim_toggle_mod_list = [
  \ ['\left', '\right'],
  \ ['\big', '\big'],
  \]
```
The `tsd` `<Plug>(vimtex-delim-toggle-modifier)` mapping would then use both `\left \right` and `\big \big`.
The VimTeX documentation explains configuring the delimiter list in more detail at `:help g:vimtex_delim_toggle_mod_list`.

Hopefully the above two examples give you a feel for setting VimTeX options; the VimTeX documentation should be able to take things from here.

## Commands
The VimTeX plugin provides a number of user-defined commands, and these are listed and described in the documentation section `:help vimtex-commands`.
The commands mostly cover compilation, PDF reader integration, and system and plugin status;
we will return to VimTeX's commands when explaining 
[compilation]({% link tutorials/vim-latex/compilation.md %}) and [PDF reader integration]({% link tutorials/vim-latex/pdf-reader.md %}) in the next two articles in this series.
There is nothing I have to say about that commands themselves that the documentation wouldn't say better; I suggest you skim through `:help vimtex-commands` and see if anything strikes your fancy.

As a side note, most but not all VimTeX commands can be triggered by default using a shortcut in the `LHS` of the three-column list in `:help vimtex-default-mappings`.
For those commands without a default shortcut mapping, defining one can be as simple as a single line of Vimscript.
Here is an example, which you could place in `ftplugin/tex.vim`, that makes the key combination `<leader>wc` call the VimTeX command `VimtexCountWords`:
```vim
" Example: make `<leader>wc` call the command `VimtexCountWords`;
" you might place this code in ftplugin/tex.vim.
noremap <leader>wc <Cmd>VimtexCountWords<CR>
```
(This mapping uses the `<Cmd>` keyword, which is a Vimscript best practice when defining mappings that specifically call commands---see `:help map-cmd` for details.)

## Syntax highlighting
VimTeX provides syntax highlighting that improves on Vim's built-in syntax plugin for LaTeX.
For most use cases VimTeX's syntax features should "just work" out of the box, and you won't need to do any configuration yourself (if you're interested in details, see `:help vimtex-syntax`).
I can think of three things worth mentioning:
- VimTeX provides correct syntax highlighting for a number of common LaTeX packages; this means, for example, that the `align` environment provided by the `amsmath` package or code listings using the `minted` package will be correctly highlighted.
  Again, you shouldn't need to configure any of this manually, but you might appreciate knowing the package-highlighting feature exists.
  See `:help vimtex-syntax-packages` and `g:vimtex_syntax_packages` for details.

- VimTeX's syntax engine is "context-aware" (e.g. can distinguish regular text from LaTeX's math mode).
  This feature makes possible math-sensitive snippet expansion, which was explained in the [snippets article]({% link tutorials/vim-latex/ultisnips.md %}) earlier in this series.

- VimTeX provides a feature called "syntax-concealment", which replaces various commands, such as math-mode commands for Greek letters, with a shorter Unicode equivalent.
  For example, the `\alpha` command would appear as the character `α` in your terminal.
  See `:help vimtex-syntax conceal` if you are interested in this feature.

## Other features
Here are a few more features to look into to learn about once you master the basics:

- VimTeX offers a ready-to-go compilation interface, which I cover in detail in the [next article in the series]({% link tutorials/vim-latex/compilation.md %}).

- VimTeX also offers ready-to-go PDF viewer integration, which I cover in a [dedicated article]({% link tutorials/vim-latex/pdf-reader.md %}) later in the series.

- VimTeX provides completion of citations and reference labels, together with integration with common autocompletion plugins.
  See `:help vimtex-completion` for more information.

- VimTeX's code-folding features are covered at `:help vimtex-folding` and the references therein.
  You have a lot of power here if you like code folding, but you may have to configure a few things yourself before the feature is practically useful.

- VimTeX provides indentation features that improve on Vim's default indentation plugin for LaTeX.
  You can read about VimTeX's indentation at `:help vimtex-indent`, which is just a list of references to associated configuration settings.
  VimTeX's indentation is enabled by default and should "just work" for most use cases, but there are plenty of configuration option for those who so choose.

- Solutions for linting and grammar checking are described at `:help vimtex-lint` and `:help vimtex-grammar`, respectively;
  I have not used these features myself and cannot offer any advice.

- Finally, VimTeX offers a few useful navigation features, covered in the documentation at `:help vimtex-navigation`.
  Here is a short summary:
  - You can navigate a LaTeX document from within Vim via a table of contents, which VimTeX builds by parsing the document for `\section` commands and their variations.
    You can read more about the table of contents feature at `:help vimtex-toc`.
  - You can jump to the TeX source code of packages, style files, and documents included with `\include{}` and `\input{}` using the `gf` shortcut;
  you can read more about this feature at `:help vimtex-includeexpr`
  - You can access the documentation of LaTeX packages imported with `\usepackage{}` using the `:VimtexDocPackage` command, which is mapped to `K` by default.
    See `:help vimtex-latexdoc` for more information. 

{% include vim-latex-navbar.html %}
