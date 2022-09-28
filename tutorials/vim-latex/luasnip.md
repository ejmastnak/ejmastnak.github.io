---
title: LuaSnip Plugin Guide for LaTeX \| Vim and LaTeX Series Part 2

prev-filename: prerequisites
prev-display-name: "« 1. Prerequisites"
next-filename: ftplugin
next-display-name: "3. Vim's ftplugin system »"

date: 2022-09-27 20:00:00 +0200
date_last_mod: 2022-06-08 18:02:37 +0200
---

{% include vim-latex-navbar.html %}

# 2. A LuaSnip guide for LaTeX workflows

{% include date.html %}

This is part two in a [seven-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim or Neovim text editors to efficiently write LaTeX documents.
This article covers snippets, which are templates of commonly reused code that, when used properly, will dramatically speed up your LaTeX writing.

## Contents of this article
<!-- vim-markdown-toc GFM -->

* [What snippets do](#what-snippets-do)
* [Getting started with LuaSnip](#getting-started-with-luasnip)
  * [Installation](#installation)
  * [First steps: snippet trigger and tabstop navigation keys](#first-steps-snippet-trigger-and-tabstop-navigation-keys)
* [Snippet files, directories, and loaders](#snippet-files-directories-and-loaders)
  * [Snippet format](#snippet-format)
  * [Loading snippets and directory structure](#loading-snippets-and-directory-structure)
    * [Snippet folders](#snippet-folders)
* [Writing snippets](#writing-snippets)
  * [Setting snippet parameters](#setting-snippet-parameters)
  * [Nodes (a first look)](#nodes-a-first-look)
    * [Text node](#text-node)
    * [Insert node](#insert-node)
  * [Options](#options)
  * [Format---a nicer syntax for writing snippets](#format---a-nicer-syntax-for-writing-snippets)
  * [Assorted snippet syntax rules](#assorted-snippet-syntax-rules)
  * [Tabstops](#tabstops)
    * [Some example LaTeX snippets](#some-example-latex-snippets)
    * [Useful: tabstop placeholders](#useful-tabstop-placeholders)
    * [Useful: mirrored tabstops](#useful-mirrored-tabstops)
    * [Useful: the visual placeholder](#useful-the-visual-placeholder)
  * [Dynamically-evaluated code inside snippets](#dynamically-evaluated-code-inside-snippets)
    * [Custom context expansion and VimTeX's syntax detection](#custom-context-expansion-and-vimtexs-syntax-detection)
    * [Regex snippet triggers](#regex-snippet-triggers)
  * [Tip: Refreshing snippets](#tip-refreshing-snippets)
* [(Subjective) practical tips for fast editing](#subjective-practical-tips-for-fast-editing)
* [Tip: A snippet for writing snippets](#tip-a-snippet-for-writing-snippets)

<!-- vim-markdown-toc -->

## What snippets do
Snippets are templates of commonly used code (for example the boilerplate code for typical LaTeX environments and commands) inserted into text dynamically using short (e.g. two- or three-character) triggers.
Without wishing to overstate the case, good use of snippets is the single most important step in the process of writing LaTeX efficiently and painlessly. 
Here is a simple example:
<!-- **TODO:** see the showing off section for full-speed --> 

<image src="/assets/images/vim-latex/ultisnips/demo.gif" alt="Writing LaTeX quickly with auto-trigger snippets"  /> 

## Getting started with LuaSnip

This tutorial will use [the LuaSnip plugin](https://github.com/L3MON4D3/LuaSnip), which is the de-facto snippet plugin in Neovim's Lua ecosystem.
Alternative: [UltiSnips article]({% link tutorials/vim-latex/ultisnips.md %}).

*UltiSnips or LuaSnip?*:

- Vim users: use UltiSnips---LuaSnip only works with Neovim
- Neovim users: I suggest LuaSnip---it is faster (I don't have benchmarks), integrates better into the Neovim ecosystem, and is free of external dependencies (UltiSnips requires Python).
  That said, UltiSnips still works fine in Neovim.

### Installation

Install LuaSnip like any other Neovim plugin using your plugin installation method of choice (e.g. Packer, Vim-Plug, native, etc.).
See the [LuaSnip README's installation section](https://github.com/L3MON4D3/LuaSnip#install) for details.
LuaSnip has no external dependencies and should be ready to go immediately after installation.

LuaSnip is a snippet engine only and intentionally ships without snippets---you have to write your own or use an existing snippet database.
It is possible to use existing snippet repositories (e.g. [`rafamadriz/friendly-snippets`](https://github.com/rafamadriz/friendly-snippets)) with some additional configuration---see the [LuaSnip README's add snippets section](https://github.com/L3MON4D3/LuaSnip#add-snippets) and `:help luasnip-loaders` if interested.
Whether you download someone else's snippets, write your own, or use a mixture of both, you should know:

1. where the text files holding your snippets are stored on your local file system, and
1. how to write, edit, and otherwise tweak snippets to suit your particular needs, so you are not stuck using someone else's without the possibility of customization.

This article covers both questions.

### First steps: snippet trigger and tabstop navigation keys

After installing LuaSnip you should immediately configure...

1. the key you use to trigger (expand) snippets
1. the key you use to move forward through a snippet's tabstops, and
1. the key you use to move backward through a snippet's tabstops.

See the [LuaSnip README's keymaps section](https://github.com/L3MON4D3/LuaSnip#keymaps) for official examples.

Setting these keymaps is easiest to do in Vimscript (because they use Vimscript's conditional ternary operator), so the examples below are in Vimscript.

**Choose one** of the following two options:

1. Use a single key (e.g. Tab) to both expand snippets and jump forward through snippet tabstops.

   ```vim
   " Expand or jump in insert mode
   imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
 
   " Jump forward through tabstops in visual mode
   smap <silent><expr> jk luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : 'jk'
   ```

   This code would make the `<Tab>` key trigger snippets *and* navigate forward through snippet tabstops---the decision is made by LuaSnip's `expand_or_jumpable` function.

1. Use two different keys (e.g. Tab and Control-K) to expand snippets and jump forward through snippet tabstops

   ```vim
   " Expand snippets in insert mode with <Tab>
   imap <silent><expr> <Tab> luasnip#expandable() ? '<Plug>luasnip-expand-snippet' : '<Tab>'

   " Jump forward in through tabstops in insert and visual mode with TODO
   imap <silent><expr> jk luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : 'jk'
   smap <silent><expr> jk luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : 'jk'
   ```

After choosing one of the above options, **set your your backward-jump keymap:**

```vim
" Jump backward
imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
```

<!-- ```vim -->
<!-- " Official recommendation -->
<!-- inoremap <silent> <S-Tab> <cmd>lua require'luasnip'.jump(-1)<Cr> -->
<!-- snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr> -->
<!-- ``` -->

A few notes:

1. Place the keymap code somewhere in you Neovim startup configuration (e.g. `init.lua`, `init.vim`, etc.).
   If you have a Lua-based config and need help running Vimscript from within Lua files, just enclose the Vimscript within `vim.cmd[[]]`, e.g.
   
   ```lua
   -- Any Lua config file, e.g. init.lua
   vim.cmd[[
      " Vimscript goes here!
   ]]
   ```
   See `:help vim.cmd()` for details.

1. The conditional ternary operator `condition ? expr1 : expr2 ` executes `expr1` if `condition` is true and executes `expr2` if `condition` is false---it is common in C and [many other languages](https://en.wikipedia.org/wiki/%3F:).
In the first `imap` mapping, for example, the ternary operator is used to map `<Tab>` to `<Plug>luasnip-expand-or-jump` if `luasnip#expand_or_jumpable()` returns `true` and to `<Tab>` if `luasnip#expand_or_jumpable()` returns `false`.

1. You need to apply tabstop navigation in both insert and visual modes, hence the use of both `imap` and `smap` for the forward and backward jump mappings.
   (Well, technically select mode and not visual mode, hence the use of `smap` and not `vmap`, but for a typical end user's purposes select and visual mode look identical---see `:help select-mode` for details.)

1. Power users: you can implement custom snippet expansion and navigation behavior by working directly with LuaSnip API functions controlling expand and jump behavior---see `:help luasnip-api-reference` (scroll down to the `jumpable(direction)` entry) for details.
   For most users the example mappings given above should be fine.

Finally, you may want to **set mappings to cycle through choice nodes**:

```vim
" Cycle forward through choice nodes with Control-f (for example)
imap <silent><expr> <C-f> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-f>'
smap <silent><expr> <C-f> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-f>'
```

Choice nodes are a more advanced tool we will cover later, so you can safely skip this step for now.

<!-- In the above GIF, I am actually using `jk` to navigate forward through snippet tabstops. -->
<!-- I find this home-row combination more efficient than `<Tab>`, but it takes some getting used to; -->
<!-- scroll down to the [(Subjective) practical tips for fast editing](#subjective-practical-tips-for-fast-editing) at the bottom of this article for more on using `jk` as a jump-forward key and similar tips. -->

## Snippet files, directories, and loaders

Warning: LuaSnip offers a lot of choices here, and the required decision-making can be overwhelming for new users.
I'll try my best to guide you through your options and give a sensible recommendation for what to choose.

### Snippet format

LuaSnip supports multiple snippet formats.
Your first step is to decide which format you will write your snippets in.
You main options are:

1. **Covered in this article:** Native LuaSnip snippets written in Lua (support for all LuaSnip features, best integration with general Neovim ecosystem)
1. Parsing third-party snippets written for another snippet engine (e.g. VS Code, SnipMate).
   Fewer features are available and complex snippets may not be parseable and will not work.

*The rest of this article covers only native LuaSnip snippets written in Lua.*
I think this makes sense because:

- People seem to have the most trouble with native LuaSnip syntax, so covering it should benefit the most people.
- Native LuaSnip snippets give you far more power, and integrate much better into the Neovim ecosystem (e.g. Tree-sitter and Telescope), than imported third-party snippets.

If you want to use third-party snippets the rest of this article will probably not be of much help to you;
see `:help luasnip-loaders`, `:help luasnip-vscode` and `:help luasnip-snipmate` instead.

### Loading snippets and directory structure

You have two ways to load snippets:

- **Covered in this article:** store snippets in text files and load snippets from the text files using LuaSnip's Lua loader feature.

- Define and load snippets in your Neovim startup files using LuaSnip's `add_snippets` function.

This article covers the Lua loader---I chose this approach because using dedicated snippet files with the Lua loader decouples your snippets from your Neovim startup configuration.
This approach is "cleaner" and more modular than writing snippets directly in, say, your `init.lua` file.
If you want to use the `add_snippets` function instead, see the documentation in `:help luasnip-api-reference`---most of this article will still be useful to you because the syntax for writing snippets is the same whether you load snippets with `add_snippets` or LuaSnip's loader.

Here's how to load snippets from Lua files:

- Store LuaSnip snippets in regular Lua files with the `.lua` extension.
  (Actually writing snippets is described soon.)
  The file's base name determines which Vim `filetype` the snippets apply to.
  For example, snippets inside the file `tex.lua` would apply to files with `filetype=tex`.
  If you want certain snippets to apply globally to *all* file types, place these global snippets in the file `all.lua`.
  (This is the same naming scheme used by UltiSnips, in case you are migrating from UltiSnips).

- By default, LuaSnip expects your snippets to live in directories called `luasnippets` placed anywhere in your Neovim `runtimepath`---this is documented in the description of the `paths` key in `:help luasnip-loaders`.

  However, you can easily override the default `luasnippets` directory name and store snippets in any directory (or set of directories) on your file system---LuaSnip's loaders let you manually specify the snippet directory path(s) to load.
 I recommend a directory in your Neovim config folder, e.g. `"${HOME}/.config/nvim/LuaSnip/"`.

- Load snippets by calling LuaSnip Lua loader's `load` fuction from somewhere in your Neovim startup config (e.g. `init.lua`, `init.vim`, etc.):

  ```lua
  -- Load all snippets from the LuaSnip directory at startup
  require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/LuaSnip/"})

  -- Lazy-load snippets---only load when required, e.g. for a given filetype
  require("luasnip.loaders.from_lua").lazy_load({paths = "~/.config/nvim/LuaSnip/"})
  ```

  Bonus: if you manually set the `paths` key when calling `load` or `lazy_load`, LuaSnip will not need to scan your entire Neovim `runtimepath` looking for `luasnippets` directories---this should save you a few milliseconds of startup time.
    
- Want to use multiple snippet directories?
  No problem---the `paths` key's value can be a table or comma-separated string of multiple directories.
  Here are two ways to load snippets from both the directory `LuaSnip1` and `LuaSnip2`:

  ```lua
  -- Two ways to load snippets from both LuaSnip1 and LuaSnip2
  -- Using a table
  require("luasnip.loaders.from_lua").lazy_load({paths = {"~/.config/nvim/LuaSnip1/", "~/.config/nvim/LuaSnip2/"}})
  -- Using a comma-separated list
  require("luasnip.loaders.from_lua").lazy_load({paths = "~/.config/nvim/LuaSnip1/,~/.config/nvim/LuaSnip2/"})
  ```
  
Full syntax for the `load` call is documented in `:help luasnip-loaders`.

#### Snippet folders

You might prefer to further organize `filetype`-specific snippets into multiple files of their own.
To do so, make a folder named with the target `filetype` inside your snippets directory.
LuaSnip will then load *all* `.lua` files inside this folder, regardless of their basename.
As a concrete example, a selection of my LuaSnip directory looks like this:

```sh
${HOME}/.config/nvim/LuaSnip/
├── all.lua
├── markdown.lua
├── python.lua
└── tex
    ├── delimiters.lua
    ├── environments.lua
    ├── fonts.lua
    └── math.lua
```

Explanation: I have a lot of `tex` snippets, so I prefer to further organize them in a dedicated subdirectory, while a single file suffices for `all`, `markdown`, and `python`.

## Writing snippets

**Think in terms of nodes:**
LuaSnip snippets are composed of nodes---think of nodes as building blocks that you put together to make snippets.
LuaSnip provides about 10 types of nodes (perhaps 4 are needed for most use cases) that offer different features---your job is to combine these nodes in ways that create useful snippets.

Here are the three components of a LuaSnip snippet:

1. A table of basic snippet parameters (e.g. the trigger, a description, the snippet's priority level, the option to auto-expand option).
   Most parameters have sensible defaults and you often only need to set the trigger.
1. A table of nodes making up the snippet.
1. *Optionally*: a table of additional arguments for more advanced workflows, for example a condition function to implementing custom logic to control snippet expansion or callback functions triggered when navigating through snippet nodes.
   You'll leave this optional table blank for most use cases.

Here is the anatomy:

```lua
require("luasnip").snippet(
  snip_params:table,  -- table of snippet parameters
  nodes:table,        -- table of snippet nodes
  opts:table          -- optional: additional snippet options
)
```

### Setting snippet parameters

Possible entries in the first table: see `:help luasnip-snippets`

For example:

```lua
s(
  { -- Table 1: snippet parameters
    trig="hi",
    dscr="An auto-triggering snippet that expands 'hi' into 'Hello, world!'",
    priority=100,
    snippetType="autosnippet"
  },
  { -- Table 2: snippet nodes
    t("Hello, world!"), -- A single text node
  }
),
```

A few keys to be comfortable with:

- `trig`: the string or Lua pattern (i.e. Lua-flavored regular expression) used to trigger the snippet.
  The only required key.
- `regTrig`: whether the snippet trigger should be treated as a Lua pattern.
  `true` or `false`; `false` by default.
- `snippetType`: `snippet` (manually triggered) or `autosnippet` (auto-triggered); `snippet` by default.

Full docs in `:help luasnip-basics`.

### Nodes (a first look)

Begin with two simple nodes: text nodes and insert nodes.
These should be easy to understand if you have used another snippet engine.

#### Text node

`:help luasnip-textnode`

Discuss new lines: pass a table of strings.

```lua
s({trig="hi"},
  {
    t({"Line 1", "Line 2", "Line 3"}),
  }
),
```

#### Insert node

`:help luasnip-insertnode`

Discuss:
- Tabstops and number order
- Tabstop `0` being exit
- Initial text

### Options

We'll return to this later.

### Format---a nicer syntax for writing snippets

FMT: https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#fmt

`:help luasnip-fmt`

Recall how every snippet requires a table of nodes?
LuaSnip's `fmt` function (`require("luasnip.extras.fmt").fmt`) returns a table of nodes.

Goal basically: get a clean overview of the snippet text.
Remove noise from text snippets.
Decouple nodes from text.

General syntax:

```lua
fmt(format:string, nodes:table of nodes, opts:table|nil) -> table of nodes
```

Discuss:
- Escaping curly braces with `{{}}`
- Use `fmta` for LaTeX, which uses `<>` as the default delimiter.
- The `delimiters` key in the optional table, e.g. `{delimiters = "<>"}`

### Assorted snippet syntax rules

- LuaSnip supports the usual `--` Lua comment---the snippet files are just files, after all.

- Backslash (i.e. `\\`) must be escape in text nodes or `fmt` strings.

- Extending snippets:

  For example

  ```lua
  -- Could place this in e.g. `ankitex.lua` or just call manually
  require('luasnip').filetype_extend("ankitex", {"tex"})
  ```

  As a classic example, you might use `extends c` inside a `cpp.snippets` file, since C++ could use many snippets from C.

- Perhaps mention priority

### Tabstops

Tabstops are predefined positions within a snippet body to which you can move by pressing the key mapped to `g:UltiSnipsJumpForwardTrigger`.
Tabstops allow you to efficiently navigate through a snippet's variable content while skipping the positions of static content.
You navigate through tabstops by pressing, in insert mode, the keys mapped to `g:UltiSnipsJumpForwardTrigger` and `g:UltiSnipsJumpBackwardTrigger`.
Since that might sound vague, here is an example of jumping through the tabstops for figure path, caption, and label in a LaTeX `figure` environment:

<image src="/assets/images/vim-latex/ultisnips/tabstops.gif" alt="Showing how snippet tabstops work"  /> 

Paraphrasing from `:help UltiSnips-tabstops`:

- You create a tabstop with a dollar sign followed by a number, e.g. `$1` or `$2`.

- Tabstops should start at `$1` and proceed in sequential order, i.e. `$2`, `$3`, and so on.

- The `$0` tabstop is special---it is always the last tabstop in the snippet no matter how many tabstops are defined.
If `$0` is not explicitly defined, the `$0` tabstop is implicitly placed at the end of the snippet.

As far as I'm aware, this is a similar tabstop syntax to that used in the popular IDE Visual Studio Code.

#### Some example LaTeX snippets
For orientation, here are two examples: one maps `tt` to the `\texttt` command and the other maps `ff` to the `\frac` command.
Note that (at least for me) the snippet expands correctly without escaping the `\`, `{`, and `}` characters as suggested in `:help UltiSnips-character-escaping` (see the second bullet in [Assorted snippet syntax rules](#assorted-snippet-syntax-rules)).

```py
snippet tt "The \texttt{} command for typewriter-style font"
\texttt{$1}$0
endsnippet

snippet ff "The LaTeX \frac{}{} command"
\frac{$1}{$2}$0
endsnippet
```
Here are the above `\texttt{}` and `\frac{}{}` snippets in action:
<image src="/assets/images/vim-latex/ultisnips/texttt-frac.gif" alt="The \texttt and \frac snippets in action"  /> 

#### Useful: tabstop placeholders
Placeholders are used to enrich a tabstop with a description or default text.
The syntax for defining placeholder text is `${1:placeholder}`.
Placeholders are documented at `:help UltiSnips-placeholders`.
Here is a real-world example I used to remind myself the correct order for the URL and display text in the `hyperref` package's `href` command:

```py
snippet hr "The hyperref package's \href{}{} command (for url links)"
\href{${1:url}}{${2:display name}}$0
endsnippet
```
Here is what this snippet looks like in practice:

<image src="/assets/images/vim-latex/ultisnips/hyperref-tabstop-placeholder.gif" alt="Demonstrating the tabstop placeholder"  /> 

#### Useful: mirrored tabstops
Mirrors allow you to reuse a tabstop's content in multiple locations throughout the snippet body.
In practice, you might use mirrored tabstops for the `\begin` and `\end` fields of a LaTeX environment.
Here is an example:

<image src="/assets/images/vim-latex/ultisnips/mirrored.gif" alt="Demonstrating mirrored tabstops"  /> 

The syntax for mirrored tabstops is what you might intuitively expect: just repeat the tabstop you wish to mirror.
For example, following is the code for the snippet shown in the above GIF; note how the `$1` tabstop containing the environment name is mirrored in both the `\begin` and `\end` commands:

```py
snippet env "New LaTeX environment" b
\begin{$1}
    $2
\end{$1}
$0
endsnippet
```
The `b` options ensures the snippet only expands at the start of line; see the [Options](#options) section for review of common UltiSnips options.
Mirrored tabstops are documented at `:help UltiSnips-mirrors`.

#### Useful: the visual placeholder

The visual placeholder lets you use text selected in Vim's visual mode inside the content of a snippet body.
Here is the how to use it:

1. Create and save an UltiSnips snippet that includes the `${VISUAL}` keyword (explained below).
1. Use Vim to open a file in which you want to trigger the snippet.
1. Use Vim's visual mode to select some text.
1. Press the Tab key (or the more generally the key stored in the `g:UltiSnipsExpandTrigger` variable, which is Tab by default).
   The selected text is deleted, stored by UltiSnips in memory, and you are placed into Vim's insert mode.
1. Type the trigger to expand the previously-written snippet that included the `${VISUAL}` keyword.
   The snippet expands, and the text you had selected in visual mode appears in place of the `${VISUAL}` keyword in the snippet body.

As an example, here is a snippet for the LaTeX `\textit` command that uses a visual placeholder to make it easer to surround text in italics:

```py
snippet tii "The \textit{} command for italic font"
\textit{${1:${VISUAL:}}}$0
endsnippet
```
And here is what this snippet looks like in action:

<image src="/assets/images/vim-latex/ultisnips/visual-placeholder.gif" alt="Demonstrating the visual placeholder"  /> 

Indeed (as far as I know) the most common use case for the visual placeholder is to quickly surround existing text with a snippet (e.g. to place a sentence inside a LaTeX italics command, to surround a word with quotation marks, surround a paragraph in a LaTeX environment, etc.).
You can have one visual placeholder per snippet, and you specify it with the `${VISUAL}` keyword---this keyword is usually (but does not have to be) integrated into tabstops.

Of course, you can still use any snippet that includes the `${VISUAL}` keyword without going through the select-and-Tab procedure described above---you just type the snippet trigger and use it like any other snippet.

The visual placeholder is documented at `:help UltiSnips-visual-placeholder` and explained on video in the UltiSnips screencast [Episode 3: What's new in version 2.0](https://www.sirver.net/blog/2012/02/05/third-episode-of-ultisnips-screencast/); I encourage you to watch the video for orientation, if needed.

### Dynamically-evaluated code inside snippets
It is possible to add dynamically-evaluated code to snippet bodies (UltiSnips calls this "code interpolation").
Shell script, Vimscript, and Python are all supported.
Interpolation is covered in `:help UltiSnips-interpolation` and in the UltiSnips screencast [Episode 4: Python Interpolation](https://www.sirver.net/blog/2012/03/31/fourth-episode-of-ultisnips-screencast/).
I will only cover two examples I subjectively find to be most useful for LaTeX:

1. making certain snippets expand only when the trigger is typed in LaTeX math environments, which is called *custom context* expansion, and

1. accessing characters captured by a regular expression trigger's capture group.

#### Custom context expansion and VimTeX's syntax detection
UltiSnips's custom context features (see `:help UltiSnips-custom-context-snippets`) give you essentially arbitrary control over when snippets expand, and one *very* useful LaTeX application is expanding a snippet only if its trigger is typed in a LaTeX math context.
As an example of why this might be useful:

- Problem: good snippet triggers tend to interfere with words typed in regular text.
  For example, `ff` is a great choice for a `\frac{}{}` snippet, but you wouldn't want `ff` to expand to `\frac{}{}` in the middle of the word "offer", for example.
- Solution: make `ff` expand to `\frac{}{}` only in math context, where it won't conflict with regular text.
  (Note that the `frac` expansion problem can also be solved with a regex snippet trigger, which is covered in the next section.)

You will need GitHub user `lervag`'s [VimTeX plugin](https://github.com/lervag/vimtex) for math-context expansion.
(I cover VimTeX in much more detail in the [fourth article in this series]({% link tutorials/vim-latex/vimtex.md %}).)
The VimTeX plugin, among many other things, provides the user with the function `vimtex#syntax#in_mathzone()`, which returns `1` if the cursor is inside a LaTeX math zone (e.g. between `$ $` for inline math, inside an `equation` environment, etc...) and `0` otherwise.
This function isn't explicitly mentioned in the VimTeX documentation, but you can find it in the VimTeX source code at [`vimtex/autoload/vimtex/syntax.vim`](https://github.com/lervag/vimtex/blob/master/autoload/vimtex/syntax.vim).

You can integrate VimTeX's math zone detection with UltiSnips's `context` feature as follows:

```py
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
My original source for the implementation of math-context expansion: [https://castel.dev/post/lecture-notes-1/#context](https://castel.dev/post/lecture-notes-1/#context).

#### Regex snippet triggers
For our purposes, if you aren't familiar with them, regular expressions let you (among many other things) implement conditional pattern matching in snippet triggers.
You could use a regular expression trigger, for example, to do something like "make `^` expand to a superscript snippet like `^{$1}$0`, but only if the `^` trigger immediately follows an alphanumeric character".

A formal explanation of regular expressions falls beyond the scope of this work, and I offer the examples below in a "cookbook" style in the hope that you can adapt the ideas to your own use cases.
Regex tutorials abound on the internet; if you need a place to start, I recommend [Corey Schafer's tutorial on YouTube](https://www.youtube.com/watch?v=sa-TUpSx1JA).

1. This class of triggers suppresses expansion following alphanumeric text and permits expansion after blank space, punctuation marks, braces and other delimiters, etc...

   ```py
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
   This is by far my most-used class of regex triggers.
   Here are some example use cases:
   - Make `mm` expand to `$ $` (inline math), including on new lines, but not in words like "communication", "command", etc...
   ```py
   snippet "(^|[^a-zA-Z])mm" "Inline LaTeX math" rA
   `!p snip.rv = match.group(1)`\$ ${1:${VISUAL:}} \$$0
   endsnippet
   ```
   Note that the dollar signs used for the inline math must be escaped (i.e. written `\$` instead of just `$`) to avoid conflict with UltiSnips tabstops, as described in `:help UltiSnips-character-escaping`.

   - Make `ee` expand to `e^{}` (Euler's number raised to a power) after spaces, `(`, `{`, and other delimiters, but not in words like "see", "feel", etc...
   ```py
   snippet "([^a-zA-Z])ee" "e^{} supercript" rA
   `!p snip.rv = match.group(1)`e^{${1:${VISUAL:}}}$0
   endsnippet
   ```

   - Make `ff` expand to `frac{}{}` but not in words like "off", "offer", etc...
   ```py
   snippet "(^|[^a-zA-Z])ff" "\frac{}{}" rA
   `!p snip.rv = match.group(1)`\frac{${1:${VISUAL:}}}{$2}$0
   endsnippet
   ```
   The line `` `!p snip.rv = match.group(1)` `` inserts the regex group captured by the trigger parentheses back into the original text.
   Since that might sound vague, try omitting `` `!p snip.rv = match.group(1)` `` from any of the above snippets and seeing what happens---the first character in the snippet trigger disappears after the snippet expands.

1. This class of triggers expands only after alphanumerical characters (`\w`) or the characters `}`, `)`, `]`, and `|`.

   ```py
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
   I don't use this one often, but here is one example I really like.
   It makes `00` expand to the `_{0}` subscript after letters and closing delimiters, but not in numbers like `100`:

   ```py
   snippet "([a-zA-Z]|[\}\)\]\|'])00" "Automatic 0 subscript" rA
   `!p snip.rv = match.group(1)`_{0}
   endsnippet
   ```
   Here is the above snippet in action:

   <image src="/assets/images/vim-latex/ultisnips/0-subscript.gif" alt="The 0 subscript snippet in action"  /> 

   
Combined with math-context expansion, these two classes of regex triggers cover the majority of my use cases and should give you enough to get started writing your own.
Note that you can do much fancier stuff than this.
See the UltiSnips documentation or look through the snippets in `vim-snippets` for inspiration.

### Tip: Refreshing snippets
The function `UltiSnips#RefreshSnippets` refreshes the snippets in the current Vim instance to reflect the contents of your snippets directory.
Here's an example use case:

- Problem: you're editing `myfile.tex` in one Vim instance, make some changes `tex.snippets` in a separate Vim instance, and want the updates to be immediately available in `myfile.tex` without having to restart Vim.

- Solution: call `UltiSnips#RefreshSnippets` using `:call UltiSnips#RefreshSnippets()`.

This workflow comes up regularly if you use snippets often, and I suggest writing a key mapping in your `vimrc` to call the `UltiSnips#RefreshSnippets()` function, for example

```vim
" Use <leader>u in normal mode to refresh UltiSnips snippets
nnoremap <leader>u <Cmd>call UltiSnips#RefreshSnippets()<CR>
```
In case it looks unfamiliar, the above code snippet is a Vim *key mapping*, a standard Vim configuration tool described in much more detail in the series's final article, [7. A Vimscript Primer for Filetype-Specific Workflows]({% link tutorials/vim-latex/vimscript.md %}).

## (Subjective) practical tips for fast editing
I'm writing this with math-heavy LaTeX in real-time university lectures in mind, where speed is crucial; these tips might be overkill for more relaxed use cases.
In no particular order, here are some useful tips based on my personal experience:

- Use automatic completion whenever possible.
  This technically makes UltiSnips use more computing resources---see the warning in `:help UltiSnips-autotrigger`---but I am yet to notice a perceptible slow-down on modern hardware.
  For example, I regularly use 100+ auto-trigger snippets on a 2.5 GHz dual-core i5 processor and 8 gigabytes of RAM (typical, even modest specs by today's standards) without any problems.

- Use *short* snippet triggers.
  Like one-, two-, or and *maybe* three-character triggers.

- Repeated-character triggers offer a good balance between efficiency and good semantics.
  For example, I use `ff` (fraction), `mm` (inline math), and `nn` (new equation environment).
  Although `frac`, `$`, and `eqn` would be even clearer, `ff`, `mm`, and `nn` still get the message across and are also much faster to type.

  Use math-context expansion and regular expressions to free up short, convenient triggers that would otherwise conflict with common words.

- Use ergonomic triggers on or near the home row.
  Depending on your capacity to develop muscle memory, you can dramatically improve efficiency if you sacrifice meaningful trigger names for convenient trigger locations.
  I'm talking weird combinations of home row keys like `j`, `k`, `l`, `s`, `d`, and `f` that smoothly roll off your fingers.
  For example, `sd`, `df`, `jk`, and `kl`, if you can get used to them, are very convenient to type and also don't conflict with many words in English or Romance languages.

  Here are two examples I use all the time:
  1. I first define the LaTeX command `\newcommand{\diff}{\ensuremath{\operatorname{d}\!}}` in a system-wide preamble file, then access it with the following snippet:

     ```py
     snippet "([^a-zA-Z0-9])df" "\diff (A personal command I universally use for differentials)" rA
     `!p snip.rv = match.group(1)`\diff 
     endsnippet
     ```
     This `df` snippet makes typing differentials a breeze, with correct spacing, upright font, and all that.
     Happily, in this case using `df` for a differential also makes semantic sense.

     You can see the `\diff` snippet playing a minor supporting role as the differential in this variation of the fundamental theorem of calculus:

     <image src="/assets/images/vim-latex/show-off/calc.gif" alt="Example use of a differential in the fundamental theorem of calculus" />

     As a side note, using a `\diff` command also makes redefinition of the differential symbol very easy---for example to adapt an article for submission to a journal that uses italic instead of upright differentials, one could just replace `\operatorname{d}\!` with `\,d` in the command definition instead of rummaging through LaTeX source code changing individual differentials.

  2. I use the following snippet for upright text in subscripts---the trigger makes no semantic sense, but I got used to it and love it.

     ```py
     # Test
     snippet "([\w]|[\}\)\]\|])sd" "Subscript with upright text" rA
     `!p snip.rv = match.group(1)`_{\mathrm{${1:${VISUAL:}}}}$0
     endsnippet
     ```
     This snippet triggers after alphanumeric characters and closing delimiters, and includes a visual placeholder.

     Please keep in mind: I'm not suggesting you should stop what you're doing, fire up your Vim config, and start using `sd` to trigger upright-text subscripts just like me.
     The point here is just to get you thinking about using the home-row keys as efficient snippet triggers.
     Try experimenting for yourself---you might significantly speed up your editing.
     Or maybe this tip doesn't work for you, and that's fine, too.

- Try using `jk` as your `g:UltiSnipsJumpForwardTrigger` key, i.e. for moving forward through tabstops.
  The other obvious choice is the Tab key, but I found the resulting pinky reach away from the home row to be a hindrance in real-time LaTeX editing.
  
  Of course `jk` is two key presses instead of one, but it rolls of the fingers so quickly that I don't notice a slowdown.
  (And you don't have `jk` reserved for exiting Vim's insert mode because you've [remapped Caps Lock to Escape on a system-wide level](https://www.dannyguo.com/blog/remap-caps-lock-to-escape-and-control/) and use that to exit insert mode, right?)

## Tip: A snippet for writing snippets
The following snippet makes it easier to write more snippets.
To use it, create the file `~/.vim/UltiSnips/snippets.snippets`, and inside it paste the following code:

```py
snippet snip "A snippet for writing Ultisnips snippets" b
`!p snip.rv = "snippet"` ${1:trigger} "${2:Description}" ${3:options}
$4
`!p snip.rv = "endsnippet"`
$0
endsnippet
```
This will insert a snippet template when you type `snip`, followed by the snippet trigger key stored in `g:UltiSnipsExpandTrigger`, at the beginning of a line in a `*.snippets` file in insert mode.
Here's what this looks like in practice:

 <image src="/assets/images/vim-latex/ultisnips/snip-snippet.gif" alt="The snippet-writing snippet in action"  /> 

The use of `` `!p snip.rv = "snippet"` `` needs some explanation---this uses the UltiSnips Python interpolation feature, described in the section on [dynamically-evaluated code inside snippets](#dynamically-evaluated-code-inside-snippets)---to insert the literal string `snippet` in place of `` `!p snip.rv = "snippet"` ``.
The naive implementation would be to write

```py
# THIS SNIPPET WON'T WORK---IT'S JUST FOR EXPLANATION!
snippet snip "A snippet for writing Ultisnips snippets" b
snippet ${1:trigger} "${2:Description}" ${3:options}
$4
endsnippet
$0
endsnippet
```
but this would make the UltiSnips parser think that the line `snippet ${1:trigger}...` starts a new snippet definition, when the goal is to insert the literal string `snippet ${1:trigger}...` into another file.
In any case, this problem is specific to using the string `snippet` inside a snippet, and most snippets are much easier to write than this.

{% include vim-latex-navbar.html %}

{% include vim-latex-license.html %}

<!-- Extras: -->
<!-- - Filetype loading https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#filetype_functions -->
