---
title: Snippets \| Setting up Vim for LaTeX Part 1
---
# UltiSnips and LaTeX

## About the series
This is part one in a [five-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents. This article covers snippets, which can dramatically speed up your LaTeX writing.

## Contents of this article
<!-- vim-markdown-toc GFM -->

* [What snippets do](#what-snippets-do)
* [Getting started with UltiSnips](#getting-started-with-ultisnips)
  * [Installation](#installation)
  * [First steps: snippet trigger and tabstop navigation keys](#first-steps-snippet-trigger-and-tabstop-navigation-keys)
  * [A home for your snippets](#a-home-for-your-snippets)
    * [Snippet folders](#snippet-folders)
* [Watch the screencasts!](#watch-the-screencasts)
* [Writing Snippets](#writing-snippets)
  * [Anatomy of an UltiSnippets snippet](#anatomy-of-an-ultisnippets-snippet)
  * [Tip: A snippet for writing snippets](#tip-a-snippet-for-writing-snippets)
  * [Options](#options)
  * [Assorted snippet syntax rules](#assorted-snippet-syntax-rules)
  * [Tabstops](#tabstops)
    * [Some examples](#some-examples)
    * [Useful: tabstop placeholders](#useful-tabstop-placeholders)
    * [Useful: mirrored tabstops](#useful-mirrored-tabstops)
    * [Useful: the visual placeholder](#useful-the-visual-placeholder)
  * [Dynamically-evaluated code inside snippets](#dynamically-evaluated-code-inside-snippets)
    * [Custom context expansion and `vimtex`'s syntax detection](#custom-context-expansion-and-vimtexs-syntax-detection)
    * [Regex snippet triggers](#regex-snippet-triggers)
  * [Tip: Refreshing snippets](#tip-refreshing-snippets)
* [(Subjective) practical tips for fast editing](#subjective-practical-tips-for-fast-editing)

<!-- vim-markdown-toc -->

## What snippets do
**TODO** Gifs of e.g. `itemize` environment followed by items, `figure` environment with tabstops, Greek letters

**TODO** also provide reference to [https://castel.dev/post/lecture-notes-1/#snippets](https://castel.dev/post/lecture-notes-1/#snippets)

## Getting started with UltiSnips

The [UltiSnips repository](https://github.com/SirVer/ultisnips)

### Installation
Install UltiSnips like any other Vim plugin using your method of choice. Because the UltiSnips plugin uses Python,
- you need a working installation of Python 3 on your system (see `:help UltiSnips-requirements`)
- your Vim must be compiled with the `python3` feature enabled---you can test this with `:echo has("python3)`, which will return `1` if `python3` is enabled and `0` otherwise. Note that Neovim comes with `python3` enabled by default.

UltiSnips intentionally ships without snippets---you have to write your own or use an existing snippet database. The canonical source of existing snippets is GitHub user `honza`'s [`vim-snippets`](https://github.com/honza/vim-snippets) repository. Whether you download someone else's snippets, write your own, or use a mixture of both, you should know:

1. where the text files storing your snippets are located on your file system, and
1. how to write and edit snippets to suit your particular needs.

Both questions are answered in this article
<!-- avoid the trap of blindly copying from the Internet without understanding what's going on under the hood. -->

### First steps: snippet trigger and tabstop navigation keys
**TODO** screen-keys GIF showing what the trigger key does and what the tabstop navigation does.

After installing UltiSnips you should configure...
1. the key you use to trigger (expand) snippets, which UltiSnips accesses from the global variable `g:UltiSnipsExpandTrigger`,
1. the key you use to move forward through a snippet's tabstops, which is set using `g:UltiSnipsJumpForwardTrigger`, and
1. the key you use to move backward through a snippet's tabstops, which is linked to  `g:UltiSnipsJumpBackwardTrigger`.

For orientation, here is an example configuration:
```vim
" This code should go in your vimrc or init.vim
let g:UltiSnipsExpandTrigger = '<Tab>'          " use Tab to expand snippets
let g:UltiSnipsJumpForwardTrigger = '<Tab>'     " use Tab to move forward through tabstops
let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'  " use Shift-Tab to move backward through tabstops
```
This code would make the `<Tab>` key trigger snippets *and* navigate forward through snippet tabstops and make the combination `<Shift>`+`<Tab>` navigate backward through tabstops. Yes, UltiSnips lets you use the same key for both expansion and tabstop navigation! (Although this might conflict with default mappings from certain autocomplete plugins---your mileage may vary.) For efficiency, I personally use `let g:UltiSnipsJumpForwardTrigger = 'jk'`---more on this in the section on [(subjective) practical tips for fast editing](#subjective-practical-tips-for-fast-editing).

See `:help UltiSnips-trigger-key-mappings` for relevant documentation. For fine-grained control one can also work directly with functions controlling expand and jump behavior; for more information on this see `:help UltiSnips-trigger-functions`. For most users just setting the three trigger key variables, as in the example above, should suffice.

### A home for your snippets
You store snippets in text files with the `.snippets` extension. The file's base name (as in `base-name.snippets`) determines which Vim `filetype` the snippets apply to. For example, snippets inside the file `tex.snippets` would apply to files with `filetype=tex`. If you want certain snippets to apply globally to *all* file types, place these global snippets in the file `all.snippets`, which is documented towards the bottom of `:help UltiSnips-how-snippets-are-loaded`.

By default, UltiSnips expects your `.snippet` files to live in directories called `UltiSnips`, which, if you wanted, you could place anywhere in your Vim `runtimepath`. You can use folder names other than the default `UltiSnips`, too---the snippet directory name is controlled with the global variable `g:UltiSnipsSnippetDirectories`. From `:help UltiSnips-how-snippets-are-loaded`,

> UltiSnips will search each 'runtimepath' directory for the subdirectory names
defined in `g:UltiSnipsSnippetDirectories` in the order they are defined.

For example, to use `MySnippets` as a snippet directory, you would place the following Vimscript in your `vimrc`:
```vim
 let g:UltiSnipsSnippetDirectories=["UltiSnips", "MySnippets"]
```
UltiSnips would then load `*.snippet` files located in both `UltiSnips` and `MySnippets` directories.

Suggested optimization: if, like me, you use only a single predefined snippet directory and don't need UltiSnips to scan your entire `runtimepath` each time you open Vim (which can slow down start-up time), set `g:UltiSnipsSnippetDirectories` to use a *single*, *absolute* path to your snippets directory, for example
```
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips']           " on Vim
let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/UltiSnips']   " on Neovim
```
(The `.` after `$HOME` is the Vimscript string concatenation operator.)

#### Snippet folders
You might prefer to further organize `filetype`-specific snippets into multiple files of their own. To do so, make a folder named with the target `filetype` inside your snippets directory. UltiSnips will then load *all* `.snippet` files inside this folder, regardless of their basename. As a concrete example, a selection of my UltiSnips directory looks like this:
```
${HOME}/.config/nvim/UltiSnips/
├── all.snippets
├── markdown.snippets
├── python.snippets
└── tex
    ├── delimiters.snippets
    ├── environments.snippets
    ├── fonts.snippets
    └── math.snippets
```
Explanation: I have a lot of `tex` snippets, so I prefer to further organize them in a dedicated directory, while a single file suffices for `all`, `markdown`, and `python`.

## Watch the screencasts!
They're old but gold, and pack a surprisingly thorough demonstration of UltiSnips' capabilities into about 20 minutes of video. Many of the features described below also appear in the screencasts.
- [Episode 1: What are snippets and do I need them?](http://www.sirver.net/blog/2011/12/30/first-episode-of-ultisnips-screencast/)
- [Episode 2: Creating Basic Snippets](http://www.sirver.net/blog/2012/01/08/second-episode-of-ultisnips-screencast/)
- [Episode 3: What's new in version 2.0](http://www.sirver.net/blog/2012/02/05/third-episode-of-ultisnips-screencast/)
- [Episode 4: Python Interpolation](http://www.sirver.net/blog/2012/03/31/fourth-episode-of-ultisnips-screencast/)

## Writing Snippets
**TLDR:** create a `{filetype}.snippets` file in your `UltiSnips` directory (e.g. `tex.snippets`) and write your snippets inside this file using the syntax described in `:help UltiSnips-basic-syntax`.

### Anatomy of an UltiSnippets snippet
The general form of an UltiSnips snippet is:
```
snippet {trigger} ["description" [options]]
{snippet body}
endsnippet
```
The `trigger` and `snippet body` are mandatory, while `"description"` (which should be enclosed in quotes) and `options` are optional; `options` can be included only if a `"description"` is also provided. The keywords `snippet` and `endsnippet` define the beginning and end of the snippet. See `:help UltiSnips-authoring-snippets` for the relevant documentation.

### Tip: A snippet for writing snippets
I suggest starting with a snippet that makes it easier to write more snippets. To do this, create the file `nvim/UltiSnips/snippets.snippets`, and inside it paste the following code:
```vim
snippet snip "A snippet for writing Ultisnips snippets" b
`!p snip.rv = "snippet"` ${1:trigger} "${2:Description}" ${3:options}
$4
`!p snip.rv = "endsnippet"`
$0
endsnippet
```
This will insert a snippet template when you type `snip`, followed by the snippet trigger key stored in `g:UltiSnipsExpandTrigger`, at the beginning of a line in a `*.snippets` file in insert mode. Here's what this looks like in practice:

**TODO** GIF showing the `snip` snippet.

The use of `` `!p snip.rv = "snippet"` `` needs some explanation---this uses the UltiSnips Python interpolation feature---more on this in the section on [dynamically-evaluated code inside snippets](#dynamically-evaluated-code-inside-snippets)---to insert the literal string `snippet` in place of `` `!p snip.rv = "snippet"` ``. The naive implementation would be to write
```
# This won't work---it's just for explanation
snippet snip "A snippet for writing Ultisnips snippets" b
snippet ${1:trigger} "${2:Description}" ${3:options}
$4
endsnippet
$0
endsnippet
```
but this would make the UltiSnips parser think that the line `snippet ${1:trigger}...` starts a new snippet definition, when the goal is to insert the literal string `snippet ${1:trigger}...` into another file. In any case, this problem specific to using the text `snippet` inside a snippet, and most snippets are much easier to write than this.

### Options
You'll need to use a few options to get the full UltiSnips experience. All options are clearly documented at `:help UltiSnips-snippet-options`, and I'll summarize here only what is necessary for understanding the snippets that appear later in this document. Based on my (subjective) experience, mostly with LaTeX files, here are some options to know:
- `A` enables automatic expansion, i.e. a snippet with the `A` option will expand immediately after `trigger` is typed, without you having to press the`g:UltiSnipsExpandTrigger` key. If you're aiming for real-time LaTeX, using well thought-out automatic snippet expansion will dramatically increase your efficiency---more on this in [(subjective) practical tips for fast editing](#subjective-practical-tips-for-fast-editing).

- `r` allows the use of regular expansions in the snippet's trigger. More on this in the section on [regex snippet triggers](#regex-snippet-triggers).

- `b` expands snippets only if `trigger` is typed at the beginning of a line---this option was used above in the [snippet for writing snippets](#tip-a-snippet-for-writing-snippets).

- `i` (for "in-word" expansion) expands snippets regardless of where `trigger` is typed. (By default snippets expand only if `trigger` begins a new line or is preceded by whitespace.)


### Assorted snippet syntax rules
- Comments start with `#` and can be used to document snippets

- According to `:help UltiSnips-character-escaping`, the characters `'`, `{`, `$`, and `\` need to be escaped by prepending a backslash `\`. That said, I'm generally able to use `'`, `{`, and `\` in snippet bodies without escaping them---your mileage may vary.

- Include the line
  ```
  extends filetype
  ```
  anywhere in a `*.snippets` file to load all snippets from `filetype.snippets` into the current snippets file. Example use case from `:help UltiSnips-basic-syntax`: you might use `extends c` inside a `cpp.snippets` file, since C++ could use many snippets from C.

- The line `priority {N}`, where `N` is an integer number (e.g. `priority 5`), placed *anywhere* in `.snippets` file on its own line will set the priority of all snippets below that line to `N`. When multiple snippets have the same `trigger`, only the highest-priority snippet is expanded. Using `priority` can be useful to override global snippets defined in `all.snipets`. If `priority` is not specified anywhere in a file, the implicit value is `priority 0`

### Tabstops
Tabstops are predefined positions within a snippet body to which you can move the cursor by pressing the key mapped to `g:UltiSnipsJumpForwardTrigger`. Tabstops allow you to efficiently navigate through a snippet's variable content while skipping the positions of static content. Since that might sound vague, here is an example:

**TODO** GIF jumping through a figure or table environment.

Paraphrasing from `:help UltiSnips-tabstops`:

- You create a tabstop with a dollar sign followed by a number, e.g. `$1` or `$2`.

- Tabstops should start at `$1` and proceed in sequential order, i.e. `$2`, `$3`, and so on.

- The `$0` tabstop is special---it is always the last tabstop in the snippet no matter how many tabstops are defined. If `$0` is not explicitly defined, the `$0` tabstop is implicitly placed at the end of the snippet.

As far as I'm aware, this is a similar tabstop syntax to that used in Visual Studio Code.

#### Some examples
For orientation, here are two examples: one maps `tt` to the `\texttt` macro and the other maps `ff` to the `\frac` macro. Note that (at least for me) the snippet expands correctly without escaping the `\`, `{`, and `}` characters as suggested in `:help UltiSnips-character-escaping` (see the second bullet in [Assorted snippet syntax rules](#assorted-snippet-syntax-rules)).
```
snippet tt "The \texttt{} macro for typewriter-style font"
\texttt{$1}$0
endsnippet

snippet ff "The LaTeX \frac{}{} macro"
\frac{$1}{$2}$0
endsnippet
```
You navigate through tabstops by pressing, in insert mode, the keys mapped to `g:UltiSnipsJumpForwardTrigger` and `g:UltiSnipsJumpBackwardTrigger`.

**TODO** show example used in above GIF.

#### Useful: tabstop placeholders
Placeholders are used to enrich a tabstop with a description or default text. The syntax for defining placeholder text is `${1:placeholder}`. Here is a real-world example I used to remind myself the correct order for the URL and display text in the `hyperref` package's `href` macro:
```
snippet hr "The hyperref package's \href{}{} macro (for url links)"
\href{${1:url}}{${2:display name}}$0
endsnippet
```
Placeholders are documented at `:help UltiSnips-placeholders`.

**TODO** GIF here is what this looks like in practice:

#### Useful: mirrored tabstops
Mirrors allow you to reuse a tabstop's content in multiple locations throughout the snippet body. In practice, you might use mirrored tabstops for the `\begin` and `\end` fields of a LaTeX environment. Here is an example:

**TODO** GIF showing an `environment` snippet.

The syntax for mirrored tabstops is what you might intuitively expect: just repeat the tabstop you wish to mirror. For example, here is the code for the snippet shown in the above GIF:
```
snippet env "New LaTeX environment" b
\begin{$1}
    $2
\end{$1}
$0
endsnippet
```
The `b` options ensures the snippet only expands at the start of line; see the [Options](#options) section. Mirrored tabstops are documented at `:help UltiSnips-mirrors`. 

#### Useful: the visual placeholder
The visual placeholder enables you to use text selected in Vim's visual mode as the content of a snippet body. The visual placeholder is useful when you want to surround existing text with a snippet (e.g. to place a sentence inside a LaTeX italics macro or to surround a word with quotation marks). Here is an example:

**TODO** GIF with e.g. `textit`

You can have one visual placeholder per snippet, and you specify it with the `${VISUAL}` keyword. This usually is (but does not have to be) integrated into tabstops. Here is the code for the example in the above GIF:
```
snippet tii "The \textit{} macro for italic font"
\textit{${1:${VISUAL:}}}$0
endsnippet
```
The visual placeholder is documented at `:help UltiSnips-visual-placeholder` and explained on video in the UltiSnips screencast [Episode 3: What's new in version 2.0](http://www.sirver.net/blog/2012/02/05/third-episode-of-ultisnips-screencast/); I encourage you to watch the video for orientation, if needed.


### Dynamically-evaluated code inside snippets
It is possible to add dynamically-evaluated code to snippet bodies (UltiSnips calls this "interpolation"). Shell scripting, Vimscript, and Python are all supported. Interpolation is covered in `:help UltiSnips-interpolation` and in UltiSnips screencast [Episode 4: Python Interpolation](http://www.sirver.net/blog/2012/03/31/fourth-episode-of-ultisnips-screencast/). I will only cover two examples I subjectively find to be most useful:
1. making certain snippets expand only the trigger is typed in LaTeX math environments, which is called *custom context* expansion, and
1. accessing characters captured by regular expression trigger's capture groups.

#### Custom context expansion and `vimtex`'s syntax detection
UltiSnips' custom context features (see `:help UltiSnips-custom-context-snippets`) give you essentially arbitrary control over when snippets expand, and one *very* useful application is expanding a snippet only if its trigger is typed in a LaTeX math context. As an example of why this might be useful:

- Problem: good snippet triggers tend to interfere with words typed in regular text. For example, `ff` is a great choice for a `\frac{}{}` snippet, but you wouldn't want `ff` to expand to `\frac{}{}` in the middle of the word "offer", for example.
- Solution: make `ff` expand to `\frac{}{}` only in math context, where it won't conflict with regular text.

You will need GitHub user `lervag`'s [`vimtex` plugin](https://github.com/lervag/vimtex) for math-context expansion. The `vimtex` plugin, among many other things, provides the user with the function `vimtex#syntax#in_mathzone()`, which returns `1` if the cursor is inside a LaTeX math zone (e.g. between `$ $` for inline math, inside an `equation` environment, etc...) and `0` otherwise. This function isn't explicitly mentioned in the `vimtex` documentation, but you can find it in the `vimtex` source code at [`vimtex/autoload/vimtex/syntax.vim`](https://github.com/lervag/vimtex/blob/master/autoload/vimtex/syntax.vim).

You can integrate `vimtex`'s math zone detection with UltiSnips' `context` feature as follows:
```
# include this code block at the top of a *.snippets file...
# ----------------------------- #
global !p
def math():
  return vim.eval('vimtex#syntax#in_mathzone()') == '1'
endglobal
# ----------------------------- #
# ...then place 'context "math()"' above any snippets you want to expand only in math mode

context "math()"
snippet ff "This \frac{}{} snippet expands only a LaTeX math context"
\frac{$1}{$2}$0
endsnippet
```
My original source for the implementation of math-context expansion: [https://castel.dev/post/lecture-notes-1/#context](https://castel.dev/post/lecture-notes-1/#context)


Note that the `frac` expansion problem can also be solved with a regex snippet, which is covered next.

#### Regex snippet triggers
For our purposes, if you aren't familiar with them, regular expressions let you (among many other things) implement conditional pattern matching in snippet triggers. You could use a regular expression trigger, for example, to do something like "make `^` expand to a superscript snippet like `^{$1}$0`, but only if the `^` trigger immediately follows an alphanumeric character".

A formal explanation of regular expressions falls beyond the scope of this work, and I offer the examples below in a "cookbook" style in the hope that you can adapt the ideas to your own use cases.

1. This class of triggers suppresses expansion following alphanumeric text and permits expansion after blank space, punctuation marks, braces and other delimiters, etc...
   ```
   snippet "([^a-zA-Z])trigger" "Expands if 'trigger' is typed after characters other than a-z or A-Z" r
   `!p snip.rv = match.group(1)`snippet body
   endsnippet

   snippet "(^|[^a-zA-Z])trigger" "Expands on a new line or after characters other than a-z or A-Z" r
   `!p snip.rv = match.group(1)`snippet body
   endsnippet

   # This trigger suppresses numbers, too
   snippet "(^|[\W])trigger" "Expands on a new line or after characters other than 0-9, a-z, or A-Z" r
   `!p snip.rv = match.group(1)`snippet body
   endsnippet
   ```
   This is by far my most-used class of regex triggers. Here are some example use cases:
   - Make `mm` expand to `$ $` (inline math), including on new lines, but not in words like "communication", "command", etc...
   ```
   snippet "(^|[^a-zA-Z])mm" "Inline LaTeX math" rA
   `!p snip.rv = match.group(1)`\$ ${1:${VISUAL:}} \$$0
   endsnippet
   ```
   Note that the dollar signs used for the inline math must be escaped (i.e. written `\$` instead of just `$`) to avoid conflict with UltiSnips tabstops, as described in `:help UltiSnips-character-escaping`.

   - Make `ee` expand to `e^{}` (Euler's number raised to a power) after spaces, `(`, `{`, and other delimiters, but not in words like "see", "feel", etc...
   ```
   snippet "([^a-zA-Z])ee" "e^{} supercript" rA
   `!p snip.rv = match.group(1)`e^{${1:${VISUAL:}}}$0
   endsnippet
   ```

   - Make `ff` expand to `frac{}{}` but not in words like "off", "offer", etc...
   ```
   snippet "(^|[^a-zA-Z])ff" "\frac{}{}" rA
   `!p snip.rv = match.group(1)`\frac{${1:${VISUAL:}}}{$2}$0
   endsnippet
   ```
   The line `` `!p snip.rv = match.group(1)` `` inserts the regex group captured by the trigger parentheses back into the original text. If sounds vague, try omitting `` `!p snip.rv = match.group(1)` `` from any of the above snippets and seeing what happens---the first character in the trigger disappears.

1. This class of triggers expands only after alphanumerical characters (`\w`) or the characters `}`, `)`, `]`, and `|`.
   ```
   snippet "([\w])trigger" "Expands if 'trigger' is typed after 0-9, a-z, and  A-Z" r
   `!p snip.rv = match.group(1)`snippet body
   endsnippet

   # Of course, modify the }, ), ], and | characters as you wish
   snippet "([\w]|[\}\)\]\|])trigger" "Expands after 0-9, a-z, A-Z and }, ), ], and |" r
   `!p snip.rv = match.group(1)`snippet body
   endsnippet

   # This trigger suppresses expansion after numbers
   snippet "([a-zA-Z]|[\}\)\]\|])trigger" "Expands after a-z, A-Z and }, ), ], and |" r
   `!p snip.rv = match.group(1)`snippet body
   endsnippet
   ```
   I don't use this one much, but here is an example I really like:
   - Make `00` expand to the `_{0}` subscript after letters and closing delimiters, but not in numbers like `100`:
   ```
   snippet "([a-zA-Z]|[\}\)\]\|'])00" "Automatic 0 subscript" rA
   `!p snip.rv = match.group(1)`_{0}
   endsnippet
   ```
   
Combined with math-context expansion, these two classes of regex triggers cover the majority of my use cases and should give you enough to get started writing your own. Note that you can do much fancier stuff than this. See the UltiSnips documentation, check out  or look through the snippets in `vim-snippets` for inspiration.

### Tip: Refreshing snippets
The function `UltiSnips#RefreshSnippets` refreshes the snippets in the current Vim instance to reflect the contents of your snippets directory. Here's an example use case:

- Problem: you're editing `myfile.tex` in one Vim instance, make some changes `tex.snippets` in a separate Vim instance, and want the updates to be immediately available in `myfile.tex` without having to restart Vim.

- Solution: call `UltiSnips#RefreshSnippets` using `:call UltiSnips#RefreshSnippets()`.

This workflow comes up regularly if you use snippets often, and I suggest writing a key binding in your `vimrc` for `:call UltiSnips#RefreshSnippets()`, for example
```vim
" Use <leader>u in normal mode to refresh UltiSnips snippets
nnoremap <leader>u :call UltiSnips#RefreshSnippets()<CR>
```

## (Subjective) practical tips for fast editing
I'm writing this with math-heavy LaTeX in real-time university lectures in mind, where speed is crucial; these tips might be overkill for more relaxed use cases.

- Use automatic completion whenever possible. This technically makes UltiSnips use more computing resources---see the warning in `:help UltiSnips-autotrigger`---but I am yet to notice a perceptible slow-down on modern hardware. For example, I regularly use 100+ auto-trigger snippets on a 2.5 GHz dual-core i5 processor and 8 gigabytes of RAM without any problems.

- Use *short* snippet triggers. Like one-, two-, or and *maybe* three-character triggers.

- Repeated-character triggers offer a good balance between efficiency and good semantics. For example, I use: `ff` (fraction), `mm` (inline math), `nn` (new equation environment). Although `frac`, `$$`, and `eqn` would be even clearer, `ff`, `mm`, and `nn` still get the message across and are also much faster.

- Use math-contex expansion and regular expressions to free up short, convenient triggers that would otherwise conflict with common words.

- Use ergonomic triggers on or near the home row. Depending on your capacity to develop muscle memory, you can dramatically improve efficiency if you sacrifice meaningful trigger names for convenient trigger locations. I'm talking weird combinations of home row keys like `j`, `k`, `l`, `s`, `d`, and `f` that smoothly roll off your fingers. For example, `sd`, `df`, `jk`, and `kl`, if you can get used to them, are very convenient to type and also don't conflict with many words in English or Romance languages.

  Here are two examples I use all the time:
  1. I first define the LaTeX macro `\newcommand{\diff}{\ensuremath{\operatorname{d}\!}}` in a system-wide preamble file, then access it with the following snippet:
     ```
     snippet "([^a-zA-Z0-9])df" "\diff (A personal macro I universally use for differentials)" rA
     `!p snip.rv = match.group(1)`\diff 
     endsnippet
     ```
     This `df` snippet makes typing differentials a breeze, with correct spacing, upright font, and all that. Happily, in this case using `df` for a differential also makes semantic sense.

     As a side note, using a `\diff` macro also makes redefinition very easy---for example to adapt an article to fit a journal that uses italic differentials, I could just replace `\operatorname{d}\!` with `\,d` in the macro definition instead of rummaging through my LaTeX source code changing individual differentials.

  2. I use the following snippet for upright text in subscripts---the trigger makes no semantic sense, but I got used to it and love it.
     ```
     snippet "([\w]|[\}\)\]\|])sd" "Subscript with upright text" rA
     `!p snip.rv = match.group(1)`_{\mathrm{${1:${VISUAL:}}}}$0
     endsnippet
     ```
     The snippet triggers after alphanumeric characters and closing delimiters, and includes a visual placeholder.

     **TODO** example LaTeX output of upright-text subscripts.

   Please keep in mind: I'm not suggesting you should stop what you're doing, fire up your Vim config, and start using `sd` to trigger upright-text subscripts just like me. The point here is just to get you thinking about home-row keys as efficient snippet triggers. Try experimenting for yourself---you might significantly speed up your editing. Or maybe this tip doesn't work for you, and that's fine, too.

- Try using `jk` as your `g:UltiSnipsJumpForwardTrigger` key, i.e. for moving forward through tabstops. The other obvious choice is the Tab key; I found the resulting pinky reach away from the home row to be a hindrance in real-time LaTeX editing. Of course `jk` is two key presses instead of one, but it rolls of the fingers so quickly that I don't notice a slowdown. (And you don't have `jk` reserved for exiting Vim's insert mode because you've [remapped Caps Lock to Escape on a system-wide level](https://www.dannyguo.com/blog/remap-caps-lock-to-escape-and-control/) and use that to exit insert mode, right?)
