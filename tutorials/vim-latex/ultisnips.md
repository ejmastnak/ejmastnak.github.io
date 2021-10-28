---
title: Snippets | Vim and LaTeX Part 1
---
# UltiSnips and LaTeX

## About the series
This is part four in a four-part series explaining how to use the Vim text editor to efficiently write LaTeX documents. This article covers snippets, which can dramatically speed up your LaTeX writing.

Visit [the introduction]({% link tutorials/vim-latex/intro.md %}) for an overview of the series. Use the list below navigate to other parts in the series...
1. [Vimscript best practices for filetype-specific plugins]({% link tutorials/vim-latex/vimscript.md %})
1. [Compiling LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %})
1. [Integrating Vim and a PDF reader]({% link tutorials/vim-latex/pdf-reader.md %})
1. [Snippets: the key to real-time LaTeX]({% link tutorials/vim-latex/ultisnips.md %})


## Contents of this article
<!-- vim-markdown-toc Marked -->

* [Getting started with UltiSnips](#getting-started-with-ultisnips)
  * [Installation](#installation)
  * [First steps](#first-steps)
  * [A home for your snippets](#a-home-for-your-snippets)
    * [Snippet folders](#snippet-folders)
    * [Refreshing snippets](#refreshing-snippets)
* [Watch the screencasts!](#watch-the-screencasts!)
* [Writing Snippets](#writing-snippets)
  * [Anatomy of an UltiSnippets snippet](#anatomy-of-an-ultisnippets-snippet)
  * [Options](#options)
  * [Assorted snippet syntax rules](#assorted-snippet-syntax-rules)
  * [Tabstops](#tabstops)
    * [Useful: tabstop placeholders](#useful:-tabstop-placeholders)
    * [Useful: mirrored tabstops](#useful:-mirrored-tabstops)
    * [Useful: the visual placeholder](#useful:-the-visual-placeholder)
  * [Dynamically-evaluated code inside snippets](#dynamically-evaluated-code-inside-snippets)
    * [Custom context expansion and `vimtex`'s syntax detection](#custom-context-expansion-and-`vimtex`'s-syntax-detection)
    * [Regex snippet triggers](#regex-snippet-triggers)
* [(Subjective) practical tips for fast editing](#(subjective)-practical-tips-for-fast-editing)

<!-- vim-markdown-toc -->

The [UltiSnips repository](https://github.com/SirVer/ultisnips)

## Getting started with UltiSnips

### Installation
UltiSnips follows the default Vim plugin installation procedure. I assume you will be able to install UltiSnips on your own. If you have never installed a Vim plugin before, I suggest you learn to do that first. The official documentation is `:help package`, while tutorials with screenshots and richer format abound on the web.

### First steps
UltiSnips comes without snippets---you have to write your own or use an existing snippet database. The canonical source of existing snippets is GitHub user `honza`'s [`vim-snippets` repository](https://github.com/honza/vim-snippets). Even if you use someone else's snippets, I encourage you to understand (i) where snippets live on your file system and (ii) how to write and edit snippets to suit your particular needs.

After installing UltiSnips you should configure...
1. the key you use to trigger (expand) snippets (linked to  `g:UltiSnipsExpandTrigger`),
1. the key you use to move forward through a snippet's possible tabstops (linked to  `g:UltiSnipsJumpForwardTrigger`), and
1. the key you use to move backward through a snippet's possible tabstops (linked to  `g:UltiSnipsJumpBackwardTrigger`).

See `:help UltiSnips-trigger-key-mappings` for relevant documenation. For fine-grained control one can also work directly with functions controlling expand and jump behavior; for more information on this see `:help UltiSnips-trigger-functions`. For most users it should suffice to just set the three trigger key variables, for example like this:
```
let g:UltiSnipsExpandTrigger = '<tab>'          # use Tab to expand snippets
let g:UltiSnipsJumpForwardTrigger = '<tab>'     # use Tab to move forward through tabstops
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'  # use Shift-Tab to move backward through tabstops
```
Yes, you can use the same key for both expansion and tabstop navigation! (Although this might conflict with default mappings from certain autocomplete plugins---YMMV.) For efficiency, I personally use `let g:UltiSnipsJumpForwardTrigger = 'jk'`---more on this in TODO.

### A home for your snippets
This topic's official documentation lives at `:help UltiSnips-how-snippets-are-loaded`.

You store snippets in text files with the `.snippets` extension. The file's base name (as in `base-name.snippets`) determines which Vim `filetype` the snippets apply to. For example, snippets inside the file `tex.snippets` would apply to files with `filetype=tex`. Want certain snippets to apply globally to *all* file types? No problem---put global snippets in the file `all.snippets`, which is covered towards the bottom of `:help UltiSnips-how-snippets-are-loaded`.

By default, UltiSnips expects your `.snippet` files to live in directories called `UltiSnips`, which, if you wanted, you could place anywhere in your Vim `runtimepath`. The snippet directory name is controled with the the global variable `g:UltiSnipsSnippetDirectories`. If, addition to `UltiSnips`, you wanted (for example) `MySnippets` to be a valid snippet directory, you would use the Vimscript
```
 let g:UltiSnipsSnippetDirectories=["UltiSnips", "MySnippets"]
```
From `:help UltiSnips-how-snippets-are-loaded`,

> UltiSnips will search each 'runtimepath' directory for the subdirectory names
defined in g:UltiSnipsSnippetDirectories in the order they are defined.

Suggested optimization: if, like me, you use only a single predefined snippet directory and don't need UltiSnips to scan your entire `runtimepath` each time you open Vim, set `g:UltiSnipsSnippetDirectories` to use a *single*, *absolute* path to your snippets directory, for example
```
let g:UltiSnipsSnippetDirectories=[$HOME.'/.vim/UltiSnips']           " Vim
let g:UltiSnipsSnippetDirectories=[$HOME.'/.config/nvim/UltiSnips']   " Neovim
```
The `.` after `$HOME` is used for Vimscript string concatenation.

#### Snippet folders
You might prefer to further organize `filetype`-specific snippets into multiple files of their own. To do so, make a folder named with the target `filetype` inside your snippets directory. Ultisnips will load *all* `.snippet` files inside this folder, regardless of their basename. For orientation, a selection of my UltiSnips directory looks like this:
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

#### Refreshing snippets
The function `UltiSnips#RefreshSnippets` refreshes the snippets in the current Vim instance to reflect the contents of your snippets directory. Use case: you're editing text in one Vim instance, update your snippets in another window, and want to continue using the initial Vim instance, with updated snippets, without having to restart Vim. The function call `:call UltiSnips#RefreshSnippets()` is your friend here. If you do this often, it might pay to define a key binding such as
```
nnoremap <leader>U :call UltiSnips#RefreshSnippets()<CR>  # use <leader>U in normal mode to refresh snippets
```

## Watch the screencasts!
They're old but gold, and pack a suprisingly thorough demonstration of UltiSnips' capabilities into about 20 minutes of video. Many of the features described below also appear in the screencasts.
- [Episode 1: What are snippets and do I need them?](http://www.sirver.net/blog/2011/12/30/first-episode-of-ultisnips-screencast/)
- [Episode 2: Creating Basic Snippets](http://www.sirver.net/blog/2012/01/08/second-episode-of-ultisnips-screencast/)
- [Episode 3: What's new in version 2.0](http://www.sirver.net/blog/2012/02/05/third-episode-of-ultisnips-screencast/)
- [Episode 4: Python Interpolation](http://www.sirver.net/blog/2012/03/31/fourth-episode-of-ultisnips-screencast/)


## Writing Snippets
TLDR: create a `{filetype}.snippets` file in your `UltiSnips` directory (e.g. `tex.snippets`) and write your snippets inside this file using the syntax described in `:help UltiSnips-basic-syntax`.

### Anatomy of an UltiSnippets snippet
The general form of an UltiSnips snippet is:
```
snippet {trigger} ["description" [options]]
{snippet body}
endsnippet
```
The `trigger` and `snippet body` are mandatory, while `"description"` (which should be enclosed in quotes) and `options` are optional; `options` can be included only if a `"description"` is also provided. The keywords `snippet` and `endsnippet` define the beginning and end of the snippet. See `:help UltiSnips-authoring-snippets` for the relevant documentation.

### Options
You'll realize pretty soon that you'll have to learn about `options` to get the full UltiSnips experience. All options are clearly documented at `:help UltiSnips-snippet-options`, while I'll summarize only what is strictly necessary for understanding the snippets that appear later in this document. Based on my (subjective) experience, mostly with LaTeX files, options you should know include:
- `A` enables automatic expansion, i.e. a snippet using `A` will expand immediately after `trigger` is typed. (By default, you would have to press the `g:UltiSnipsExpandTrigger` key after `trigger` to expand a snippet.) I find well-configured automatic snippet expansion highly conducive to an efficient workflow.
- `r` allows the use of regular expansions in the snippet's trigger. More on this in TODO
- `b` expands snippets only if `trigger` is typed at the beginning of a line.
- `i` (for "in-word" expansion) expands snippets regardless of where `trigger` is typed. (By default snippets expand only if `trigger` begins a new line or is preceded by whitespace.)


### Assorted snippet syntax rules
- Comments start with `#` and can be used to document snippets

- According to `:help UltiSnips-character-escaping`, the characters `'`, `{`, `$`, and `\` need to be escaped by prepending a backslash `\`. That said, I'm generally able to use `'`, `{`, and `\` in snippet bodies without escaping them---YMMV.

- Include the line
  ```
  extends filetype
  ```
  anywhere in a `snippet` file to load all snippets from `filetype.snippets` into the current snippets file. Example use case from the documentation: you might use `extends c` inside the `cpp.snippets` file, since C++ would reasonably reuse many snippets from C.

- The line `priority {N}`, where `N` is an integer number (e.g. `priority 5`), placed anywhere in `.snippets` file sets the priority of all snippets below that line to `N`. When multiple snippets have the same `trigger`, only the higher-priority snippet is expanded. Using `priority` can be useful to override global snippets defined in `all.snipets`.

  If `priority` is not specified anywhere in a file, the implicit value is `priority 0`


### Tabstops
Tabstops are predefined positions within a snippet body to which you can move the cursor by pressing the key mapped to `g:UltiSnipsJumpForwardTrigger`. Tabstops allow you to efficiently navigate through a snippet's positions of variable content while skipping the positions of static content. Paraphrasing from `:help UltiSnips-tabstops`:


> The syntax for a tabstop is the dollar sign followed by a number, e.g. `$1`. 
> Tabstops start at `$1` and are followed in sequential order with `$2`, `$3`, and so on.
> The `$0` tabstop is special---it is always the last tabstop in the
> snippet no matter how many tabstops are defined. If `$0` is not explicitly defined,
> the `$0` tabstop is implicitly placed at the end of the snippet.

As far as I'm aware, this is a similar tabstop syntax to that used in Visual Studio Code.

For orientation, here are two examples mapping `tt` to the `\texttt` macro `ff` to the `\frac` macro. Note that (at least for me) the snippet expands correctly without escaping the `\`, `{`, and `}` characters.
```
snippet tt "The \texttt{} macro for typewriter-style font"
\texttt{$1}$0
endsnippet

snippet ff "The LaTeX \frac{}{} macro"
\frac{$1}{$2}$0
endsnippet
```
You jump between tabstops by pressing the key mapped to `g:UltiSnipsJumpForwardTrigger`.


#### Useful: tabstop placeholders
Placeholders are used to enrich a tabstop with a description or default text. The syntax for defining placeholders is `${1:placeholder}`. Here is a a real-world example I used to remind myself the correct order for the URL and display text in the `hyperref` package's `href` macro:
```
snippet hr "The hyperref package's \href{}{} macro (for url links)"
\href{${1:url}}{${2:display name}}$0
endsnippet
```
Placeholders are documented at `:help UltiSnips-placeholders`.

#### Useful: mirrored tabstops
Mirrors allow you to reuse a tabstop's content in multiple locations throughout the snippet body. In practice, you might use mirrored tabstops for the `\begin` and `\end` fields of a LaTeX environment. The syntax for mirrored tabstops is what you would intuitively expect: just use repeat the tabstop number you wish to mirror. For illustrative purposes, here is a hypothetical environment snippet using mirrored tabstops:
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
The visual placeholder enables you to use text selected in Vim's visual mode as the content of a snippet body. The visual placeholder is useful when you want to surround existing text with a snippet (e.g. to place a sentence inside a LaTeX italics macro or to surround a word with quotation marks). You can have one visual placeholder per snippet, defined with the `${VISUAL}` keyword. This can be (and usually is) integrated into tabstops; here is an example:
```
snippet tii "The \textit{} macro for italic font"
\textit{${1:${VISUAL:}}}$0
# \textit{${1:${VISUAL:placeholder text}}}$0  # you can add placeholders, too!
endsnippet
```
The visual placeholder is documented at `:help UltiSnips-visual-placeholder` and explained on video in the UltiSnips screencast [Episode 3: What's new in version 2.0](http://www.sirver.net/blog/2012/02/05/third-episode-of-ultisnips-screencast/); I encourage you see video for orientation, if needed.


### Dynamically-evaluated code inside snippets
- It is possible to include dynamically-evaluated code in your snippet bodies (UltiSnips calls this "interpolation"). Shell scripting, Vimscript, and Python are all supported. Interpolation is covered in `:help UltiSnips-interpolation` and in UltiSnips screencast [Episode 4: Python Interpolation](http://www.sirver.net/blog/2012/03/31/fourth-episode-of-ultisnips-screencast/). I will only cover two examples I subjectively find to be most useful:
1. Custom context for triggering snippet expansion, which I use to make certain snippets expand only in LaTeX math environments
1. Access to characters captured by the regular expression capture groups I use in regex snippets

#### Custom context expansion and `vimtex`'s syntax detection
UltiSnips custom context capabilities (see `:help UltiSnips-custom-context-snippets`) give you highly-configurable control over which snippets expand in what context. I will only show one practical use case: expanding a snippet only if its trigger is typed in a LaTeX math context. 

Motivation: good snippet triggers tend to interfere with words typed in regular text. For example, you might map `ff` to a `\fraction{}{}` snippet, but you probably wouldn't want `ff` to expand if you typed the word 'off' in regular text. Many context problems can be resolved with well-designed regex triggers alone, but math-only expansion can solve troublesome corner cases. You will need to install GitHub user `lervag`'s [VimTeX plugin](https://github.com/lervag/vimtex) for this to work.

The VimTeX plugin, among many other things, provides the user with the function `vimtex#syntax#in_mathzone()`, which returns `1` if the cursor is inside a LaTeX math zone (e.g. between `$ $` for inline math, inside an `equation` environment, etc...) and `0` otherwise. This function is defined in `vimtex/autoload/vimtex/syntax.vim`, but I have not seen it in the `vimtex` documentation.

You can integrate `vimtex#syntax#in_mathzone()` with UltiSnips' `context` feature as follows:
```
# include this code block at the top of a .snippets file...
# ----------------------------- #
global !p
def math():
	return vim.eval('vimtex#syntax#in_mathzone()') == '1'
endglobal
# ----------------------------- #
# ...then place 'context "math()"' above any snippets you want to expand only in math mode

context "math()"
snippet ff "an example \frac{}{} snippet to illustrate custom context"
\frac{$1}{$2}$0
endsnippet
```

Source [https://castel.dev/post/lecture-notes-1/#context](https://castel.dev/post/lecture-notes-1/#context)

#### Regex snippet triggers
A formal explanation of regular expressions falls beyond the scope of this work. I offer the examples below in a "cookbook" style.

1. Snippet does *not* expand if trigger follows alphanumeric text and expands otherwise
   ```
   snippet "([^a-zA-Z])trigger" "expands if 'trigger' is typed after anything other than a-z, or A-Z" r
   `!p snip.rv = match.group(1)`snippet body
   endsnippet

   snippet "(^|[^a-zA-Z])trigger" "expands on a new line or after anything other than a-z, or A-Z" r
   `!p snip.rv = match.group(1)`snippet body
   endsnippet
   ```
   A variation excluding numbers:
   ```
   snippet "([\W])trigger" "expands if 'trigger' is typed after anything other than 0-9, a-z, or A-Z" r
   `!p snip.rv = match.group(1)`snippet body
   endsnippet

   snippet "(^|[\W])trigger" "expands on a new line or after anything other than 0-9, a-z, or A-Z" r
   `!p snip.rv = match.group(1)`snippet body
   endsnippet
   ```
   The line `` `!p snip.rv = match.group(1)` `` ensures the regex group captured by the trigger parentheses doesn't disappear from the text after expanding the snippet. Try omitting `` `!p snip.rv = match.group(1)` `` and see what happens.

1. Two variations that expand after alphanumerical characters (`\w`) or the characters `}`, `)`, `]`, and `|`
  ```
  snippet "([\w])trigger" "expands if 'trigger' is typed after 0-9, a-z, and  A-Z" r
  `!p snip.rv = match.group(1)`snippet body
  endsnippet

  snippet "([\w]|[\}\)\]\|])trigger" "expands after 0-9, a-z, A-Z and }, ), ], and |" r
  `!p snip.rv = match.group(1)`snippet body
  endsnippet
  ```
  These two classes of regex triggers cover the majority of my use cases and should give you enough to get started writing your own.

You can do much fancier stuff than this. See the UltiSnips documentation or look through the snippets in `vim-snippets` for inspiration.
  
## (Subjective) practical tips for fast editing
I'm talking math-heavy LaTeX in real-time university lectures, where speed is crucial. The tips below might be overkill for more easygoing use cases.

- Use automatic completion where ever possible. (As mentioned in `:help UltiSnips-autotrigger`, UltiSnips will use more resources if automatic completion is enabled, but in my experience this is hardly noticeable on modern hardware.)

- Use short snippet triggers. Like one-, two-, or maybe three-character triggers.

- Use ergonomic triggers. Depending on your capacity to develop muscle memory, it can do wonders, especially for commonly-used snippets, to optimize trigger efficiency at the expense of semantics. I'm talking wierd combinations of home row keys like `j`, `k`, `l`, `s`, `d`, and `f` that smoothly roll off your fingers.

  For example: I don't use the obvious choices `^^` and `__` to trigger superscript and subscript but instead use `jl` and `j;`. Like, TF, `jl`, what does that have to do with subscripts, right? But it works.

- Repeated-character triggers offer a good balance between efficiency and semantics. For example, I use: `ff` (fraction), `mm` (inline math), `nn` (new equation environment). Although `frac`, `$$`, and `eqn` could be even more semantically clear, `ff`, `mm`, and `nn` still get the message across and are much faster.

- Use `context` and regular expression triggers to control snippet expansion.

<!-- ## LaTeX Snippets -->
