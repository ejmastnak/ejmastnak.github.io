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
    * [Snippet filetype subdirectories](#snippet-filetype-subdirectories)
  * [Heads up---some abbreviations](#heads-up---some-abbreviations)
* [Writing snippets](#writing-snippets)
  * [Setting snippet parameters](#setting-snippet-parameters)
    * [A common shortcut you'll see in the wild](#a-common-shortcut-youll-see-in-the-wild)
* [Writing snippets 101](#writing-snippets-101)
  * [Text node](#text-node)
  * [Insert node](#insert-node)
  * [Format: a human-friendly syntax for writing snippets](#format-a-human-friendly-syntax-for-writing-snippets)
    * [`fmt` is a function that returns a table of nodes](#fmt-is-a-function-that-returns-a-table-of-nodes)
    * [Using the format function](#using-the-format-function)
  * [Insert node tips and tricks](#insert-node-tips-and-tricks)
    * [Repeated nodes](#repeated-nodes)
    * [Custom snippet exit point with the zeroth insert node](#custom-snippet-exit-point-with-the-zeroth-insert-node)
    * [Insert node placeholder text](#insert-node-placeholder-text)
  * [The visual placeholder and a few advanced nodes](#the-visual-placeholder-and-a-few-advanced-nodes)
* [Conditional snippet expansion](#conditional-snippet-expansion)
  * [The problem and the solution](#the-problem-and-the-solution)
  * [Regex snippet triggers](#regex-snippet-triggers)
    * [Expansion only at the start of a new line](#expansion-only-at-the-start-of-a-new-line)
    * [Intermezzo: function nodes and regex captures](#intermezzo-function-nodes-and-regex-captures)
    * [Suppress expansion after alphanumeric characters.](#suppress-expansion-after-alphanumeric-characters)
    * [Exand only after alphanumeric characters and closing delimiters](#exand-only-after-alphanumeric-characters-and-closing-delimiters)
  * [Expansion only in math contexts](#expansion-only-in-math-contexts)
  * [Tip: Refreshing snippets](#tip-refreshing-snippets)
* [(Subjective) practical tips for fast editing](#subjective-practical-tips-for-fast-editing)
* [Tip: A snippet for writing snippets](#tip-a-snippet-for-writing-snippets)

<!-- vim-markdown-toc -->

## What snippets do
Snippets are templates of commonly used code (for example the boilerplate code for typical LaTeX environments and commands) inserted into text dynamically using short (e.g. two- or three-character), easy-to-type character sequences called *triggers*.
Without wishing to overstate the case, good use of snippets is the single most important step in the process of writing LaTeX efficiently and painlessly. 

Here is a simple example using snippets to create and navigate through a LaTeX figure environment, quickly typeset an equation, and easily insert commands for Greek letters.

<image src="/assets/images/vim-latex/ultisnips/demo.gif" alt="Writing LaTeX quickly with auto-trigger snippets"  /> 

## Getting started with LuaSnip

This tutorial will use [the LuaSnip plugin](https://github.com/L3MON4D3/LuaSnip), which is the de-facto snippet plugin in Neovim's Lua ecosystem.
Alternative: [UltiSnips article]({% link tutorials/vim-latex/ultisnips.md %}).

*UltiSnips or LuaSnip?*:

- Vim users: use UltiSnips---LuaSnip only works with Neovim
- Neovim users: I suggest LuaSnip---it is faster (I don't have benchmarks), integrates better into the Neovim ecosystem, and is free of external dependencies (UltiSnips requires Python).
  That said, UltiSnips still works fine in Neovim.

### Installation

Install LuaSnip like any other Neovim plugin using your plugin installation method of choice (e.g. Packer, Vim-Plug, the native package management system, etc.), which I assume you know how to do.
See the [LuaSnip README's installation section](https://github.com/L3MON4D3/LuaSnip#install) for details.
LuaSnip has no external dependencies and should be ready to go immediately after installation.

LuaSnip is a snippet engine only and intentionally ships without snippets---you have to write your own or use an existing snippet database.
It is possible to use existing snippet repositories (e.g. [`rafamadriz/friendly-snippets`](https://github.com/rafamadriz/friendly-snippets)) with some additional configuration---see the [LuaSnip README's add snippets section](https://github.com/L3MON4D3/LuaSnip#add-snippets) and `:help luasnip-loaders` if interested.
I encourage you to write your own snippets,
but whether you download someone else's snippets, write your own, or use a mixture of both, you should know:

1. where the text files holding your snippets are stored on your local file system, and
1. how to write, edit, and otherwise tweak snippets to suit your particular needs, so you are not stuck using someone else's without the possibility of customization.

This article answers both questions.

### First steps: snippet trigger and tabstop navigation keys

After installing LuaSnip you should immediately configure...

1. the key you use to trigger (expand) snippets
1. the key you use to move forward through a snippet's tabstops, and
1. the key you use to move backward through a snippet's tabstops.

<!-- See the [LuaSnip README's keymaps section](https://github.com/L3MON4D3/LuaSnip#keymaps) for official examples. -->

Setting these keymaps is easiest to do in Vimscript (because they use Vimscript's conditional ternary operator), so the examples below are in Vimscript.

**Choose one** of the following two options:

1. Use a single key (e.g. Tab) to both expand snippets and jump forward through snippet tabstops.

   ```vim
   " Expand or jump in insert mode
   imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
 
   " Jump forward through tabstops in visual mode
   smap <silent><expr> jk luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : 'jk'
   ```

   This code would make the `<Tab>` key trigger snippets *and* navigate forward through snippet tabstops---the decision whether to expand or jump is made by LuaSnip's `expand_or_jumpable` function.

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
   If you have a Lua-based config and need help running Vimscript from within Lua files, just enclose the Vimscript within a multiline string and pass it to `vim.cmd`, e.g.
   
   ```lua
   -- Any Lua config file, e.g. init.lua
   vim.cmd[[
      " Vimscript goes here!
   ]]
   ```
   If needed, see `:help vim.cmd()` for details.

1. In case it's unfamiliar, the conditional ternary operator `condition ? expr1 : expr2 ` executes `expr1` if `condition` is true and executes `expr2` if `condition` is false---it is common in C and [many other languages](https://en.wikipedia.org/wiki/%3F:).
In the first `imap` mapping, for example, the ternary operator is used to map `<Tab>` to `<Plug>luasnip-expand-or-jump` if `luasnip#expand_or_jumpable()` returns `true` and to `<Tab>` if `luasnip#expand_or_jumpable()` returns `false`.

1. You need to apply tabstop navigation in both insert and visual modes, hence the use of both `imap` and `smap` for the forward and backward jump mappings.
   (Well, technically select mode and not visual mode, hence the use of `smap` and not `vmap`, but for a typical end user's purposes select and visual mode look identical.
   See `:help select-mode` for details.)

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

This section explains where to store snippets on your file system, what file format to use, and how to make LuaSnip load the snippets for actual use.

Warning: LuaSnip offers a lot of choices here, and the required decision-making can be overwhelming for new users.
I'll try my best to guide you through your options and give a sensible recommendation for what to choose.

### Snippet format

LuaSnip supports multiple snippet formats.
Your first step is to decide which format you will write your snippets in.
You main options are:

1. **Covered in this article:** Native LuaSnip snippets written in Lua (support for all LuaSnip features, best integration with the general Neovim ecosystem)
1. Use third-party snippets written for another snippet engine (e.g. VS Code, SnipMate) and try to parse them with LuaSnip's various snippet loaders.
   Fewer features are available, and complex snippets may not be parseable and will not work.

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

Here's how to **load snippets from Lua files**:

- Store LuaSnip snippets in regular Lua files with the `.lua` extension.
  (The syntax for actually writing snippets is described soon.)
  The file's base name determines which Vim `filetype` the snippets apply to.
  For example, snippets inside the file `tex.lua` would apply to files with `filetype=tex`.
  If you want certain snippets to apply globally to *all* file types, place these global snippets in the file `all.lua`.
  (This is the same naming scheme used by UltiSnips, in case you are migrating from UltiSnips).

- By default, LuaSnip expects your snippets to live in directories called `luasnippets` placed anywhere in your Neovim `runtimepath`---this is documented in the description of the `paths` key in `:help luasnip-loaders`.

  However, you can easily override the default `luasnippets` directory name and store snippets in any directory (or set of directories) on your file system---LuaSnip's loaders let you manually specify the snippet directory path(s) to load.
 I recommend using a directory in your Neovim config folder, e.g. `"${HOME}/.config/nvim/LuaSnip/"`.

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
  -- 1. Using a table
  require("luasnip.loaders.from_lua").lazy_load({paths = {"~/.config/nvim/LuaSnip1/", "~/.config/nvim/LuaSnip2/"}})
  -- 2. Using a comma-separated list
  require("luasnip.loaders.from_lua").lazy_load({paths = "~/.config/nvim/LuaSnip1/,~/.config/nvim/LuaSnip2/"})
  ```
  
Full syntax for the `load` call is documented in `:help luasnip-loaders`.

#### Snippet filetype subdirectories

You might prefer to further organize `filetype`-specific snippets into multiple files of their own.
To do so, make a subdirectory named with the target `filetype` inside your main snippets directory.
LuaSnip will then load *all* `*.lua` files inside this filetype subdirectory, regardless of the individual files' basenames.
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

Explanation: I have a lot of `tex` snippets, so I prefer to further organize them in a dedicated subdirectory with individual files for LaTeX delimiters, environments, and so on, while a single file suffices for `all`, `markdown`, and `python`.

### Heads up---some abbreviations

**TLDR:** most LuaSnip modules are a bit verbose.
LuaSnip defines a globablly-available set of abbreviations for common (sub)modules that make writing snippets much easier.
These abbreviations are listed below, and you'll see them in this document, the LuaSnip docs, and elsewhere on the Internet.
**End TLDR**.

For example, you define a LuaSnip by calling `require("luasnip").snippet()`; LuaSnip shortens this by introducing the abbreviations

```lua
local ls = require("luasnip")
local s = ls.snippet
```

You could then replace `require("luasnip").snippet()` by simply writing `s()`.
The full list of abbreviations is below---you can find it yourself in the LuaSnip docs just above the section `:help luasnip-basics` and (at the time of writing) around line 120 of the source file `LuaSnip/lua/luasnip/config.lua`.

```lua
-- Abbreviations used in this article and the LuaSnip docs
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local m = require("luasnip.extras").m
local lambda = require("luasnip.extras").l
local postfix = require("luasnip.extras.postfix").postfix
```

I'll use the full names the first few times for the sake of completeness,
but will transition to the abbreviations later.
Just know the that the mysterious-looking `s`s and `t`s and `i`s are defined!

## Writing snippets

**Think in terms of nodes:**
LuaSnip snippets are composed of *nodes*---think of nodes as building blocks that you put together to make snippets.
(Actual node syntax is described soon.)
LuaSnip provides a bit under 10 types of nodes;
each node offers a different feature---your job is to combine these nodes in ways that create useful snippets.
(Fortunately, only about 4 nodes are needed for most use cases.)

You create snippets by specifying:

1. the snippet's basic parameters (trigger, name, etc.),
1. the snippet's nodes, and
1. possibly some custom expansion conditions and callback functions.

Here is the anatomy of a LuaSnip snippet in code:

```lua
require("luasnip").snippet(
  snip_params:table,  -- table of snippet parameters
  nodes:table,        -- table of snippet nodes
  opts:table|nil      -- *optional* table of additional snippet options
)
```

And here is an English language summary of the arguments:

1. `snip_params`: a table of basic snippet parameters.
   This is where you put the snippet's trigger, description, and priority level, autoexpansion policy, and so on.
1. `nodes`: a table of nodes making up the snippet (the most important part!).
1. `opts`: an *optional* table of additional arguments for more advanced workflows, for example a condition function to implementing custom logic to control snippet expansion or callback functions triggered when navigating through snippet nodes.
   You'll leave this optional table blank for most use cases.

I'll first cover the `snip_params` table, then spend most of the remainder of this article explaining various nodes and their use cases.

### Setting snippet parameters

**TLDR** (if you're familiar with Lua):
`snip_params` is a Lua table;
the data type and purpose of each table key is clearly stated in `:help luasnip-snippets` (just sroll jdown just a bit).

**If you're not familiar with Lua tables**, you:

- define any Lua table, including the `snip_params` table, with curly braces, 
- find the list of possible table parameter keys in the LuaSnip docs at `:help luasnip-snippets`,
- use `key=value` syntax to set each of the table's keys.

Since that might sound vague, here is a concrete example of a "Hello, world!" snippet with a bunch of parameters manually specified, to give you a feel for how this works.

```lua
require("luasnip").snippet(
  { -- Table 1: snippet parameters
    trig="hi",
    dscr="An auto-triggering snippet that expands 'hi' into 'Hello, world!'",
    regTrig=false,
    priority=100,
    snippetType="autosnippet"
  },
  { -- Table 2: snippet nodes (don't worry about this for now---we'll cover nodes shortly)
    t("Hello, world!"), -- A single text node
  }
),
```

This snippet expands the trigger string `"hi"` into the string `"Hello, world!"`;
we have given the snippet a human-readable description (with `dscr`),
explicitly specified that the trigger is not a Lua regular expression (with `regTrig=false`),
lowered the snippet's priority to `100` (the default is `1000`),
and made the snippet autoexpand by setting `snippetType="autosnippet"`.

Don't worry about the `t("Hello, world!")` part for now---this is a *text node*, which we'll cover shortly.
Note also that I've left out the optional third table of advanced options---it's not needed here.

You should probably read through `:help luasnip-snippets` to see the full list of table parameter keys (e.g. `trig`, `dscr`, etc.).
You usually only use a few keys and leave the rest with their default values;
we'll only need the following parameters in this guide:

<!-- *TODO:* update as needed. -->

- `trig`: the string or Lua pattern (i.e. Lua-flavored regular expression) used to trigger the snippet.
- `regTrig`: whether the snippet trigger should be treated as a Lua pattern.
  A `true`/`false` boolean value; `false` by default.
- `snippetType`: either the string `"snippet"` (manually triggered) or `"autosnippet"` (auto-triggered); `'snippet'` by default.

#### A common shortcut you'll see in the wild

The `trig` key is the only required snippet key,
and if you only need to set `trig`, you can use the following shorthand syntax:

```lua
-- Shorthand example: the same snippet as above, but only setting the `trig` param
s("hi", -- the snip_param table is replaced by a single string holding `trig`
  { -- Table 2: snippet nodes
    t("Hello, world!"),
  }
),
```

Explanation: notice that the `snip_param` table of snippet parameters is gone---if you only want to set the `trig` key, you can replace the parameter table with a single string, and LuaSnip will interpret this string as the value of the `trig` key.
You'll see this syntax a lot in the LuaSnip docs and on the Internet, so I wanted to show it here, but in this article I'll always explicitly specify the `trig` key and use a parameter table, which I think is clearer for new users.

That's all for setting snippet parameters---let's write some actual snippets!

## Writing snippets 101

### Text node

- **Purpose:** Text nodes insert static text into a snippet.
- **Docs:** `:help luasnip-textnode`
- **Use case:** when used on their own, text nodes can transform a short, easy-to-type trigger into a longer, inconvenient-to-type piece of text.
  When used with other nodes, text nodes are usually used to create static boilerplate text, into which you dynamically insert variable text using, for example, insert or dynamic nodes.

- **How to use:** pass a string or a table of strings to `require("luasnip").text_node()` (abbreviated `t()`).

Here's a barebones "Hello, world!" example that expands the trigger `hi` into the string "Hello, world!".

```lua
s(
  {trig = "hi"}, -- Table of snippet parameters
  { -- Table of snippet nodes
    t("Hello, world!")
  }
),
```

And here are some actual real-life examples I use to easily insert the Greek letter LaTeX commands `\alpha`, `\beta`, and `\gamma`:

```lua
s({trig=";a", snippetType="autosnippet"},
  {
    t("\\alpha"),
  }
),
s({trig=";b", snippetType="autosnippet"},
  {
    t("\\beta"),
  }
),
s({trig=";g", snippetType="autosnippet"},
  {
    t("\\gamma"),
  }
),
```

Note that you have to escape the backslash character to insert it literally---for example I have to write `t("\\alpha")` to produce the string `\alpha` in the first snippet.

The only other caveat with text nodes is **multiline strings**: if you want to insert multiple lines with a single text node, write each line as a separate string and wrap the strings in a Lua table.
Here is a concrete example of a three-line text node.

```lua
s({trig = "txt1", dscr = "Demo: a text node with three lines."},
  {
    t({"Line 1", "Line 2", "Line 3"})
  }
),
```

### Insert node

Summary

- **Purpose:** dynamically type text at a given position within a snippet.
- **Docs:** `:help luasnip-insertnode`
- **How to use:** pass a tabstop number, and optionally some initial text, to `ls.insert_node`.

Insert nodes are positions within a snippet at which you can dynamically type text.
We've seen that a text node inserts *static* pieces of text---insert nodes allow you to *dynamically* type whatever text you like.
If you are migrating from UltiSnips or SnipMate, LuaSnip insert nodes are analogous to other snippet engines' tabstops (`$1`, `$2`, etc.).

You usually combine insert nodes with text nodes to insert variable content (using the insert nodes) into generic surrounding boilerplate (created by the text nodes).
Here are two concerete LaTeX examples using the LaTeX `\texttt` and `\frac` commands---I use text nodes to create the static boilerplace text and place insert nodes between the curly braces to dynamically type the commands' arguments:

<image src="/assets/images/vim-latex/ultisnips/texttt-frac.gif" alt="The \texttt and \frac snippets in action" /> 

And here is the corresponding code:

```lua
s({trig="tt", dscr="Expands 'tt' into '\texttt{}'"},
  {
    t("\\texttt{"), -- remember: backslashes need to be escaped
    i(1),
    t("}"),
  }
),
-- Yes, these jumbles of text nodes and insert nodes get messy fast, and yes,
-- there is a much better, human-readable solution: ls.fmt, described shortly.
s({trig="ff", dscr="Expands 'ff' into '\frac{}{}'"},
  {
    t("\\frac{"),
    i(1),  -- insert node 1
    t("}{"),
    i(2),  -- insert node 2
    t("}")
  }
),
```

**Insert node numbering:** notice that you can place multiple insert nodes in a snippet (the `\frac` snippet, for example, has two).
You specify the order in which you jump through insert nodes with a natural number (1, 2, 3, etc.) passed to the `i()` node as a mandatory argument and actually navigate forward and backward through the insert nodes by pressing the keys mapped to `<Plug>luasnip-jump-next` and `<Plug>luasnip-jump-prev`, respectively (i.e. the keys mapped at the start of this article in the section [First steps: snippet trigger and tabstop navigation keys](#first-steps-snippet-trigger-and-tabstop-navigation-keys)).

<!-- Since that might sound vague, here is an example of jumping through the tabstops for figure path, caption, and label in a LaTeX `figure` environment: -->
<!-- <image src="/assets/images/vim-latex/ultisnips/tabstops.gif" alt="Showing how snippet tabstops work"  />  -->

### Format: a human-friendly syntax for writing snippets

<!-- Docs: `:help luasnip-fmt` -->
**The problem:** you've probably noticed that combinations of insert nodes and text nodes become hard to read very quickly.
Consider, for example, this snippet for a LaTeX equation environment:

```lua
-- Example: text and insert nodes quickly become hard to read.
s({trig="eq", dscr="A LaTeX equation environment"},
  {
    t({ -- using a table of strings for multiline text
        "\\begin{equation}",
        "    "
      }),
    i(1),
    t({
        "",
        "\\end{equation}"
      }),
  }
),
```

<!-- *TODO:* click to see the rendered text with details/summary -->
<!-- The snippet inserts an equation that looks like this: -->
<!-- ```tex -->
<!-- \begin{equation} -->
<!--     % Cursor is here -->
<!-- \end{equation} -->
<!-- ``` -->

This code is not particularly human-readable---the jumble of text and insert node code does not *look like* the nicely-indented LaTeX `equation` environment the code produces.
The code is software-friendly (it is easy for LuaSnip to parse) but it is not *human-friendly*.

LuaSnip solves the human-readability problem with its `fmt` and `fmta` functions.
The point of these functions is to give you a clean overview of what the rendered snippet will actually look like.
Here is the same `equation` environment snippet written with `fmt`:

<!-- (the full names are `require("luasnip.extras.fmt").fmt` and `require("luasnip.extras.fmt").fmta`). -->

```lua
-- The same equation snippet, using LuaSnip's fmt function.
-- The snippet is not shorter, but it is more *human-readable*.
s({trig="eq", dscr="A LaTeX equation environment"},
  fmt( -- The snippet code actually looks like the equation environment it produces.
    [[
      \begin{equation}
          <>
      \end{equation}
    ]],
    -- The insert node is placed in the <> angle brackets
    { i(1) },
    -- This is where I specify that angle brackets are used as node positions.
    { delimiters = "<>" },
  )
),
```

Don't worry, we'll break the snippet down piece by piece---I just wanted to first show what the final product looks like.

#### `fmt` is a function that returns a table of nodes

LuaSnip's `fmt` (the full name is `require("luasnip.extras.fmt").fmt`) is just a function that returns a table of nodes, and lets you create these nodes in a relatively human-readable way.
The point is: although `fmt` is a new technique, it is not *conceptually* different from how we've been creating snippets so far---it is just another way to supply a snippet with table of nodes.

Here's a big picture perspective:

```lua
-- What we've done so far: write a snippet by specifying node table manaully
require("luasnip").snippet(
  snip_params:table,
  nodes:table,        -- manually specified node table
  opts:table|nil
)

-- Alternative: using the fmt function to create the node table
require("luasnip").snippet(
  snip_params:table,
  fmt(args),          -- fmt returns the node table
  opts:table|nil
)
```

I explain how to actually use the `fmt` function below.

#### Using the format function

The `fmt` function's call signature looks like this:

```lua
fmt(format:string, nodes:table of nodes, fmt_opts:table|nil) -> table of nodes
```

The `fmta` function is almost identical to `fmt`---`fmt` uses `{}` curly braces as the default node placeholder and `fmta` uses `<>` angle brackets (this will make sense in just a moment).
The `fmta` function is more convient for LaTeX, which itself uses curly braces to specify command and environment arguments, so I'll mostly use `fmta` below.

And here's **how to call the `fmta` function**:

1. Format string: use a Lua string (you can use quotes for single-line strings and `[[]]` for multiline strings) to create the snippet's boilerplate text, and place `<>` angle brackets at the positions where you want to place insert (or other non-text) nodes.
   Here are examples of the earlier LaTeX snippets:
 
   ```lua
   -- \texttt snippet
   "\\texttt{<>}"
 
   -- \frac snippet
   "\\frac{<>}{<>}"
 
   -- Equation snippet, using a multiline Lua string.
   -- (No need to escape backslashes in multiline strings.)
   [[
     \begin{equation*}
         <>
     \end{equation*}
   ]]
   ```

   Escaping delimiters: if you want to insert a delimiter character literally, just repeat it.
   For example, `<<>>` would insert literal angle brackets into a `fmta` string, and `{% raw %}{{}}{% endraw %}` would insert literal curly braces into a `fmt` string.
 
1. Node table: Write one node for each angle bracket node placeholder in the boilerplate string.
   Wrap the resulting list of nodes in a Lua table.
   The `fmta` function will insert the nodes in this table, in sequential order, into the angle bracket placeholders in the boilerplate string.
 
1. Format options: optionally create a third table of format options in `key = value` syntax.
   In practice, you will usually only ever need the `delimiter` key, which you can use with regular `fmt` to specify delimiters other than `fmt`'s default `{}` curly braces.
   See the `opts` entry in `:help luasnip-fmt` for the full list of possible keys.
 
Then pass the format string, node table, and optional `fmt_opts` table (if you're using one) as agruments to `fmt()` or `fmta()`.
As always, here are concrete examples---I'll continue with the `\texttt`, `\frac`, and `equation` snippets.

```lua
-- fmta call for the \texttt snippet
fmta(
  "\\texttt{<>}",
  { i(1) },
)

-- Example: using fmt's `delimiters` key to manually specify angle brackets
fmt(
  "\\frac{<>}{<>}",
  {
    i(1),
    i(2)
  },
  {delimiters = "<>"} -- manually specifying angle bracket delimiters
)

-- Using a multiline string for the equation snippet
fmta(
   [[
     \begin{equation*}
         <>
     \end{equation*}
   ]],
   { i(1) }
)
```

Finally, you create a snippet by using the call to the `fmt` or `fmta` function in place of a node table.
At the risk of getting boring---I know I'm going slowly here, but I want to make sure everyone understands---here are the `\texttt`, `\frac`, and `equation` examples as complete snippets.

```lua
-- Examples of complete snippets using fmt and fmta

-- \texttt
s({trig="tt", dscr="Expands 'tt' into '\texttt{}'"},
  fmta(
    "\\texttt{<>}",
    { i(1) },
  )
),
-- \frac
s({trig="ff", dscr="Expands 'ff' into '\frac{}{}'"},
  fmt(
    "\\frac{<>}{<>}",
    {
      i(1),
      i(2)
    },
    {delimiters = "<>"} -- manually specifying angle bracket delimiters
  )
),
-- Equation
s({trig="eq", dscr="Expands 'eq' into an equation environment"},
  fmta(
     [[
       \begin{equation*}
           <>
       \end{equation*}
     ]],
     { i(1) },
  )
)
```

See `:help luasnip-fmt` for complete documentation of `fmt` and `fmta`, although the above should have you covered for most use cases.

### Insert node tips and tricks

#### Repeated nodes

Repeated nodes (analogous to what UltiSnips calls mirrored tabstops) allow you to reuse a node's content in multiple locations throughout the snippet body.
In practice, you might use repeated insert nodes to simultaneously fill out the `\begin` and `\end` fields of a LaTeX environment.

Here is an example:

<image src="/assets/images/vim-latex/ultisnips/mirrored.gif" alt="Demonstrating repeated nodes" /> 

The syntax for repeated nodes straightforward: you pass the index of the node you want to repeat to a `rep(index:number)` node, which is provided by the `luasnip.extras` module.
For example, here is the code for the snippet shown in the above GIF---note how the `rep(1)` node in the environment's `\end` command repeats the `i(1)` node in the `\begin` command.

```lua
s({trig="env", snippetType="autosnippet"},
  fmta(
    [[
      \begin{<>}
          <>
      \end{<>}
    ]],
    {
      i(1),
      i(2),
      rep(1),
    }
  )
),
```

Repeated nodes are are documented, in passing, in the section `:help luasnip-extras`.

#### Custom snippet exit point with the zeroth insert node

By default, you exit/complete a snippet with your cursor placed at the very last piece of text.
(In the previous environment snippet, for example, this would be after the `\end{}` command.)
But sometimes it is convenient to complete a snippet with your cursor still inside the snippet body.

You can specify a custom exit point using the zero-index insert node `i(0)` (which is analogous to `$0` in UltiSnips).
The `i(0)` node is always the last node jumped to, and you use it to specify the desired cursor position when the snippet completes.
Here is an example where an explicitly-specified `i(0)` node makes you exit a equation snippet with you cursor conveniently placed inside the environment's body.

```lua
s({trig="eq", dscr=""},
  fmta(
    [[
      \begin{equation}
          <>
      \end{equation}
    ]],
    { i(0) }
  )
),
```

If `i(0)` is not explicitly defined, an `i(0)` node is implicitly placed at the very end of the snippet---in this case this would be after the `\end{equation}` command.
The zero-index insert node is documented in `:help luasnip-insertnode`.

#### Insert node placeholder text

Placeholder text is used to give an insert node a description or default text.
You define placeholder text by passing an optional second string argument to an insert node; the call signature is

```lua
i(index:number, placeholder_text:string|nil)
```

Here is a real-world example I used to remind myself the correct order for the URL and display text in the `hyperref` package's `href` command:

```lua
s({trig="hr", dscr="The hyperref package's href{}{} command (for url links)"},
  fmta(
    [[\href{<>}{<>}]],
    {
      i(1, "url"),
      i(2, "display name"),
    }
  )
),
```
Here is what this snippet looks like in action:

<image src="/assets/images/vim-latex/ultisnips/hyperref-tabstop-placeholder.gif" alt="Demonstrating the tabstop placeholder"  /> 

See the end `:help luasnip-insertnode` for official documentation of insert node placeholder text.

### The visual placeholder and a few advanced nodes

We've barely scratched the surface of what LuaSnip can do.
Using three nodes called *function nodes*, *dynamic nodes*, and *snippet nodes*, you can create nodes that call custom Lua functions and even recursively return other nodes, which opens up a world of possibilities.
This section explains, cookbook-style, how to port an UltiSnips feature called the *visual placeholder* to LuaSnip.

The visual placeholder lets you use text selected in Vim's visual mode inside the content of a snippet body.
Visual selection is an opt-in feature;
to enable it, open your LuaSnip config and set the `store_selection_keys` option to the key you want to use to trigger visual selection.
 The following example uses the Tab key, but you could use any key you like.
  
 ```lua
 -- Somewhere in your Neovim startup, e.g. init.lua
 local ls = require("luasnip")
 ls.config.set_config({ -- Setting LuaSnip config
   -- Use <Tab> (or some other key if you prefer) to trigger visual selection
   store_selection_keys = "<Tab>",
 })
 ```

Pressing `<Tab>` in visual mode will then store the visually-selected text in a LuaSnip variable called `SELECT_RAW`, which we will reference later to retrieve the visual selection.

Here's **how to use visual placeholder snippets** (it sounds really complicated when written out, but should make more sense in the GIF below and will quickly become part of your muscle memory):

1. Create and save a LuaSnip snippet with a dynamic node that calls the `get_visual` function (all of this is described below, with a complete example---I'm just giving an overview for now).
1. Use Vim to open a file in which you want to test out the just-created snippet.
1. Use Vim's visual mode to select some text.
1. Press the Tab key (or whatever other key you set earlier with `store_selection_keys`).
   The selected text is deleted and stored in the LuaSnip variable `SELECT_RAW`, and you are placed into Vim's insert mode.
1. Type the trigger to expand the previously-written snippet that included the dynamic node calling the `get_visual` function.
   The snippet expands, and the text you had selected in visual mode and stored in `SELECT_RAW` appears in place of the dynamic node in the snippet body.

As an example, following is a snippet for the LaTeX `\textit` command that uses a visual placeholder to make it easer to surround text in italics.
Here is what this snippet looks like in action:

<image src="/assets/images/vim-latex/ultisnips/visual-placeholder.gif" alt="Demonstrating the visual placeholder"  /> 

Notice how I select the text and hit Tab, and after I trigger the snippet (with `tii` in this case) the `\textit{}` command's argument is automatically populated with the previously-selected text.

Here is the corresponding snippet code:

```lua
-- This is the `get_visual` function I've been talking about.
-- ----------------------------------------------------------------------------
-- Summary: If `SELECT_RAW` is populated with a visual selection, returns an
-- insert node whose initial text is set to the visual selection.
-- If `SELECT_RAW` is empty, simply returns an empty insert node.
local get_visual = function(args, parent)
  if (#parent.snippet.env.SELECT_RAW > 0) then
    return sn(nil, i(1, parent.snippet.env.SELECT_RAW))
  else  -- If SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end
-- ----------------------------------------------------------------------------

-- Example: italic font implementing visual selection
s({trig = "tii", dscr = "Expands 'tii' into LaTeX's textit{} command."},
  fmta("\\textit{<>}",
    {
      d(1, get_visual),
    }
  )
),
```

A few comments:

- You only need to write the `get_visual` function once per snippet file---you can then use it in all snippets in the file.
  By the way, there is no need to use the name `get_visual`.
  You could name the function anything you like.
- You're probably wondering what the heck is a dynamic node---good question.
  A full answer falls beyond the scope of this article; see `:help luasnip-dynamicnode` for details.
  For our purposes, a dynamic node takes a numeric index (just like an insert node) as its first argument and a Lua function as its second argument, and this function (`get_visual` in the above example), returns a LuaSnip construct called a snippet node that *contains other nodes* (a single insert node in the above example).
- In the above example the dynamic node has an index of 1, but you can of course set a dynamic node's index to anything you like if other nodes come earlier.
  So, for example, you might first create a snippet that first uses an insert node `i(1)` and only then uses a visual dynamic node `d(2, get_visual)`.

**Use case for visual selection:** as far as I know, the most common use case for the visual placeholder is to quickly surround existing text with a snippet (e.g. to place a sentence inside a LaTeX italics command, to surround a word with quotation marks, surround a paragraph in a LaTeX environment, etc.).

Here's the great thing: you can still use any snippet that includes the `d(1, get_visual)` dynamic node without going through the select-and-Tab procedure described above---if there is no active visual selection, the dynamic node simply acts as a blank insert node.

**Docs:** This use of dynamic nodes and `SELECT_RAW` to create a visual-selection snippet is not itself mentioned in the LuaSnip docs, but you can read about `SELECT_RAW` individually at `:help luasnip-variables` and about dynamic nodes, as mentioned earlier, at `:help luasnip-dynamicnode`.
The `store_selection_keys` config key is documented in the [LuaSnip README's config section](https://github.com/L3MON4D3/LuaSnip#config).

## Conditional snippet expansion

### The problem and the solution

If you haven't noticed already, sooner or later you'll run into **the following problem**: 

> *Short, easy-to-type snippet triggers tend to interfere with words typed in regular text.*

This problem becomes particularly noticeable if you use autotrigger snippets, (which I strongly encourage if you need to type LaTeX quickly and conveniently).
For example:

- `ff` is a great choice to trigger a `\frac{}{}` snippet---it's a short, convenient trigger with good semantics---but you wouldn't want `ff` to spontaneously expand to `\frac{}{}` in the middle of typing the word "offer" in regular text, for example.
  <!-- **TODO:** a GIF would be really nice here, e.g. -->
  <!-- % Don't want this to happen -->
  <!-- Unwanted snippet expansion... pisses me off! -> ... pisses me o\frac{}{} -->
- `mm` is a nice trigger for `$ $` (inline math), but expansion would be unnacceptable when typing words like "communication", "command", etc.

You get the idea---loosely, we need a way to "stop snippets from expanding when we don't want them to".
This section gives three **solutions to this problem**:

1. Regular expansion (regex) triggers
1. Making certain snippets expand only when the trigger is typed in LaTeX math contexts
1. Making certain snippets expand in specific LaTeX environments (e.g. only in `tikzpicture` environments)

In combination, these techniques should solve your snippet expansion problems in all typical use cases.
I'll cover regex triggers first, since they apply to any filetype workflow, and then cover math-specific and environment-specific expansion, which are more LaTeX-specific.

<!-- accessing characters captured by a regular expression trigger's capture group. -->

### Regex snippet triggers

For our purposes, if you aren't familiar with them, regular expressions let you implement conditional pattern matching in snippet triggers.
You could use a regular expression trigger, for example, to do something like "make the trigger `ff` expand to the fraction snippet `\frac{i(1)}{i(2)}`, but only if the `ff` does not come after an alphabetical character".
(That would solve the problem of `ff` expanding in words like "off" or "offer".)

**Technicality: Lua patterns vs. traditional regexps:** the Lua language, and thus LuaSnip, uses a flavor of regular expressions called "Lua patterns", which basically provide a simple, limited subset of what "traditional" (e.g. POSIX or Perl) regular expressions can do.
If you're already familiar with traditional regex syntax, Lua patterns will be easy for you---for our purposes, the only meaningful difference is that Lua patterns use the percent sign instead of the backslash to escape characters, 
and I'll use the terms "regex" and "Lua pattern" interchangeably in this article.

A formal explanation of regular expressions and Lua patterns falls beyond the scope of this article, and I offer the examples below in a "cookbook" style in the hope that you can adapt the ideas to your own use cases.
Regex tutorials abound on the internet; if you need a place to start, I recommend first watching [Corey Schafer's YouTube tutorial on traditional regexes](https://www.youtube.com/watch?v=sa-TUpSx1JA), then reading the Programming in Lua book's [section on Lua patterns](https://www.lua.org/pil/20.2.html).

For future reference, here are the Lua pattern keywords needed for this article:

<!-- **TODO:** center the table -->

| Keyword | Matched characters |
| ------- | ------------------ |
| `.`	 |  all characters |
| `%d` |	digits |
| `%l` |	lower case letters |
| `%u` |	upper case letters |
| `%a` |	letters |
| `%w` |	alphanumeric characters |
| `%s` |	white space characters |
| `%p` |	punctuation characters |

**Here's how the following sections will work:**

- I'll first give the generic snippet parameter table needed to use each class of regex triggers, and use `foo` as the example trigger.
- I'll give a short explanation of each Lua regex works.
- I'll give a few real life examples I personally find useful when writing LaTeX.

#### Expansion only at the start of a new line

(This is the equivalent of the UltiSnips `b` option.)

Use case: trigger environments, `\section`-stye commands, preamble commands, and anything else you define only at the start of a new line.
Here is the snippet parameter table:

```lua
-- Snippet parameter table for new line expansion
{trig="^([%s]*)foo", regTrig = true}
```

Explanation: `^` matches the start of a new line,
`[%s]*` matches 0 or more white spaces,
and `([%s]*)` saves the white spaces in a capture group, so they can be inserted back into the snippet body for proper indentation.
Note that **you need to set `regTrig=true`** in the snippet parameter table for the trigger to be interpreted as a Lua pattern---you'll see this `regTrig=true` option in each of the snippets below.

Here are a few real-life examples of this option:
one uses the HTML-inspired trigger `h1` to create LaTeX `\section` commands (you could use `h2` for `\subsection`, and so on),
and the other uses `new` to create a new environment.

```lua
s({trig = "^([%s]*)h1", regTrig = true, dscr = "Top-level section"},
  fmta(
    [[\section{i(1)}]],
    { i(1) }
  )
),

s({trig="^([%s]*)new", regTrig = true, dscr = "A generic new environment"},
  fmta(
    [[
      \begin{<>}
          <>
      \end{<>}
    ]],
    {
      i(1),
      d(2, get_visual),
      rep(1),
    }
  )
),
```

#### Intermezzo: function nodes and regex captures

**TLDR:** when you see weird-looking function nodes like `f( function(_, snip) return snip.captures[1] end )` popping up in future regex-triggered snippets, this node is just inserting regex capture groups from snippet's trigger back into the snippet body.
You can now move to the next section.
**End TLDR**.

You might have noticed that **the above snippets have a problem:**
in the new environment snippet, for example,
the entire pattern `"^([%s]*)new"` (including leading whitespace `([%s]*)`) is interpreted as the snippet trigger, not just the string `"new"`,
and so any leading white space is never inserted back into the snippet and disappears!
The result looks like this...

<div class="language-tex highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="c">% Note the indent        % You get this...   </span>|<span class="c">   % ...but probably wanted this</span>
<span class="c">% before "new"           </span><span class="nt">\begin{document}</span>    |   <span class="nt">\begin{document}</span> 
<span class="nt">\begin{document}</span>         <span class="nt">\begin{}</span>            |       <span class="nt">\begin{}</span>         
    new            --&gt;       <span class="c">% cursor here</span>   |           <span class="c">% cursor here</span>
<span class="nt">\end{document}</span>           <span class="nt">\end{}</span>              |       <span class="nt">\end{}</span>           
                         <span class="nt">\end{document}</span>      |   <span class="nt">\end{document}</span>   
</code></pre></div></div>

Notice how the second, "correct" example saved the four spaces originally present before the `new` trigger and thus preserves indentation.
Since this might still seem vague, try copying and triggering the above environment snippet on a new line with (say) four leading whitespaces, and notice how the whitespace disappears.

**The solution:** access the leading whitespace from the trigger's regex capture group and insert it back into the snippet.
You can access regex capture groups with LuaSnip function nodes---the syntax looks like this:

```lua
f( function(_, snip) return snip.captures[1] end ) -- return first capture group
f( function(_, snip) return snip.captures[1] end ) -- return second capture group, etc.
```

The corrected environment snippet, with any leading whitespace preserved, would then look like this:

```lua
s({trig="^([%s]*)new", regTrig = true, dscr = "A generic new environment"},
  fmta(
    [[
      <>\begin{<>}
      <>    <>
      <>\end{<>}
    ]],
    {
      f( function(_, snip) return snip.captures[1] end ), -- line 1: for before \begin
      i(1),
      f( function(_, snip) return snip.captures[1] end ), -- line 2: for environment body
      d(2, get_visual),
      f( function(_, snip) return snip.captures[1] end ), -- line 3: for before \end
      rep(1),
    }
  )
),
```

A bit verbose, to be sure, but in practice you basically only write the capture group function node once and then copy and paste it into your other snippets, so it's not to bad.

#### Suppress expansion after alphanumeric characters.

The following trigger expands after blank spaces, punctuation marks, braces and other delimiters, but not after alphanumeric characters.
Here are the snippet parameter tables for a few variations on the same theme:

```lua
-- Won't expand if 'foo' is typed after letters
 s({trig = "([^%a])foo", regTrig = true}

-- Won't expand if 'foo' is typed after alphanumeric characters
 s({trig = "([^%w])foo", regTrig = true}
```

Explanation: `%a` represents letters;
the `^` character, *when used in square brackets*, performs negation, so `[^%a]foo` will negate (reject) all matches when `foo` is typed after a letter;
and `([^%a])` captures matched non-letter characters to insert back into the snippet body.
(You get behavior similar to this out of the box from LuaSnip's default `wordTrig` snippet parameter (mentioned in `:help luasnip-snippets`), but I prefer the above triggers for finer-grained control.)

This is by far my most-used class of regex triggers, because it prevents common snippet triggers from expanding in regular words.
Here are some example use cases:

- Make `mm` expand to `$ $` (inline math), but not in words like "comment", "command", etc...

  ```lua
  s({trig = "([^%a])mm", regTrig = true},
    fmta(
      "<>$<>$",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual),
      }
    )
  ),
  ```
  
  The `d(1, get_visual)` node implements the visual selection [covered earlier](#the-visual-placeholder-and-a-few-advanced-nodes) in this article.

- Make `ee` expand to `e^{}` (Euler's number raised to a power) after spaces, delimiters, and so on, but not in words like "see", "feel", etc...

  ```lua
  s({trig = '([^%a])ee', regTrig = true},
    fmta(
      "<>e^{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        d(1, get_visual)
      }
    )
  ),
  ```

- Make `ff` expand to `frac{}{}` but not in words like "off", "offer", etc...

  ```lua
  s({trig = '([^%a])ff', regTrig = true},
    fmta(
      "<>\frac{<>}{<>}",
      {
        f( function(_, snip) return snip.captures[1] end ),
        i(1),
        i(2)
      }
    )
  ),
  ```

#### Exand only after alphanumeric characters and closing delimiters

This class of triggers expands only after letter characters and closing delimiters, but not after blank spaces or numbers.

```lua
-- Only after letters
s({trig = '([%a])foo', regTrig = true}

-- Only after letters and closing delimiters
s({trig = '([%a%)%]%}])foo', regTrig = true}
```

Explanation: `%a` matches letters;
`%)`, `%]`, and `%}` match closing parentheses, square brackets, and curly braces, respectively (these three characters have to be escaped with the percent sign);
and `([%a%)%]%}])` saves the captured characters in a capture group.

I don't use this trigger that often, but here is one example I really like.
It makes `00` expand to the `_{0}` subscript after letters and closing delimiters, but not in numbers like `100`:

```lua
s({trig = '([%a%)%]%}])00', regTrig = true},
  fmta(
    "<>_{<>}",
    {
      f( function(_, snip) return snip.captures[1] end ),
      t("0")
    }
  )
),
```

And here is the above snippet in action:

<image src="/assets/images/vim-latex/ultisnips/0-subscript.gif" alt="The 0 subscript snippet in action"  /> 

   
Combined with math-context expansion (described below), these three classes of regex triggers cover the majority of my use cases and should give you enough tools to get started writing your own snippets.

### Expansion only in math contexts

**External dependency:** you need [**the VimTeX plugin**](https://github.com/lervag/vimtex/) (which I cover in detail [later in the series]({% link tutorials/vim-latex/vimtex.md %})) to detect math contexts in LaTeX files.
(But the general technique of LuaSnip conditional expansion works in any filetype and does not require VimTeX, so this section should be useful even if you don't use LaTeX.)

The `condition` option in a LuaSnip snippet's optional `opts` table (see `:help luasnip-snippets` and scroll down to the section on the `opts` table) gives you essentially arbitrary control over when snippets expand.

Set the `condition` key to a function that returns a boolean value that determines if the snippet should expand or not.
By writing your own condition functions, you have essentially arbitrary control over when snippets expand;
this article covers two relatively simple, but *very* useful expansion conditions:
expanding snippets only if the trigger is typed in:

- LaTeX math contexts.
- specific LaTeX environments.

<!-- ```lua -->
<!-- fn(line_to_cursor:string, matched_trigger:string, captures:table) -> bool -->
<!-- ``` -->
<!-- The function  -->

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
<!-- YOU CANT HAVE UNESCAPED BACKSLASHES IN DSCR -->

<!-- ### Extending snippets: -->
<!---->
<!-- For example -->
<!---->
<!-- ```lua -->
<!-- -- Use both HTML and JavaScript snippets in Vue files -->
<!-- require('luasnip').filetype_extend("vue", {"html", "javascript"}) -->
<!---->
<!-- -- Use C snippets in C++ files -->
<!-- require('luasnip').filetype_extend("c++", {"c"}) -->
<!-- ``` -->
<!---->
<!-- Search docs for `filetype_extend`---there is an entry in `:help luasnip-api-reference`. -->
