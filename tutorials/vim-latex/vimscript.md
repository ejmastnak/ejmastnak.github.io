---
title: Vimscript Theory \| Setting Up Vim for LaTeX Part 5
---
# Vimscript Theory for Filetype-Specific Workflows

## About the series
This is part six in a [six-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents.
This article provides a theoretical background for use of Vimscript in filetype-specific workflows and aims to give you a foundation for understanding the filetype plugin system, key mapping syntax, and Vimscript functions used earlier in this series.

## Contents of this article
<!-- vim-markdown-toc GFM -->

* [How to read this article](#how-to-read-this-article)
* [The basics of file-specific Vim plugins](#the-basics-of-file-specific-vim-plugins)
  * [What is a plugin?](#what-is-a-plugin)
  * [Runtimepath: where Vim looks for files to load](#runtimepath-where-vim-looks-for-files-to-load)
  * [Vim's filetype plugin system](#vims-filetype-plugin-system)
    * [Filetype plugin basic recipe](#filetype-plugin-basic-recipe)
    * [Automatic filetype detection](#automatic-filetype-detection)
    * [Manual filetype detection](#manual-filetype-detection)
    * [How Vim loads filetype plugins](#how-vim-loads-filetype-plugins)
* [Key mappings](#key-mappings)
  * [Writing key mappings](#writing-key-mappings)
    * [Map modes](#map-modes)
    * [Map arguments](#map-arguments)
    * [Leader key](#leader-key)
  * [Listing mappings and getting information](#listing-mappings-and-getting-information)
  * [Script-local mappings](#script-local-mappings)
    * [Recipe: mapping to script-local functions](#recipe-mapping-to-script-local-functions)
    * [Understanding what could go wrong if you don't follow best practices](#understanding-what-could-go-wrong-if-you-dont-follow-best-practices)
* [Writing Vimscript functions](#writing-vimscript-functions)
  * [About this section](#about-this-section)
  * [Function definition syntax](#function-definition-syntax)
    * [Tip: Best practice for naming functions](#tip-best-practice-for-naming-functions)
    * [Note: Another way of defining functions](#note-another-way-of-defining-functions)
  * [Script-local functions](#script-local-functions)
    * [Scope of script-local functions](#scope-of-script-local-functions)
    * [Why use script-local functions?](#why-use-script-local-functions)
    * [Calling script-local functions using SID key mappings](#calling-script-local-functions-using-sid-key-mappings)
  * [Autoload functions](#autoload-functions)

<!-- vim-markdown-toc -->

## How to read this article
This article is long.
You don't have to read everything---in fact, if you are already familiar with Vimscript or if you find theory boring, feel free to skip the article entirely.
I suggest skimming through on a first reading, remembering this article exists, and then referring back to it, if desired, when you wish to better understand the Vimscript functions and key mappings used in the series.
Note that this article is not a comprehensive Vimscript tutorial, just a (hopefully) coherent explanation---aimed at beginners---of the few Vimscript concepts used in this series.

By the way, nothing in this article is LaTeX-specific and would generalize perfectly to Vim workflows with other file types.

## The basics of file-specific Vim plugins

### What is a plugin?
Officially, as defined in `:help plugin`, a *plugin* is the name for a Vimscript file that is loaded when you start Vim.
If you have every created a `vimrc` or `init.vim` file, which are just simple Vimscript files, you have technically written a Vim plugin.
Just like your `vimrc`, a plugin's purpose is to extend Vim's default functionality to meet your personal needs.

A *package*, as defined in `:help packages`, is a set of Vimscript files.
To be pedantic, what most people (myself included) refer to in everyday usage as a Vim plugin is technically a package.
That's irrelevant; the point is that plugins and packages are just Vimscript files used to extend Vim's default functionality, and, if you have ever written a `vimrc` or `init.vim`, it is within your means to write more advanced plugins, too.

### Runtimepath: where Vim looks for files to load
Your Vim *`runtimepath`* is a list of directories, both in your home directory and system-wide, that Vim searches for files to load at runtime, i.e. when opening Vim.
Below is a list of some directories on Vim's default `runtimepath`, taken from `:help runtimepath`---you will probably recognize some of them from your own Vim setup.

| Directory or File | Description |
| ----------------- | ----------- |
| `filetype.vim` |	Used to set a file's Vim filetype |
| `autoload` |	Scripts loaded dynamicly using Vim's `autoload` feature |
| `colors/` | Vim colorscheme files conventionally go here | 
| `compiler/` | Contains files related to compilation and `make` functionality | 
| `doc/` | Contains documentation and help files | 
| `ftplugin/` | Filetype-specific configurations go here | 
| `indent/` | Contains scripts related to indentation | 
| `pack/` | Vim's default location for third-party plugins | 
| `spell/` | Files related to spell-checking | 
| `syntax/` | Contains scripts related to syntax highlighting | 

You can view your current `runtimepath` with `:echo &runtimepath`.
If you want a plugin to load automatically when you open Vim, you must place the plugin in an appropriate location in your `runtimepath`.

For the purposes of this series, the most important directory in your `runtimepath` is the `ftplugin/` directory in your Vim config folder, i.e. the directory `~/.vim/ftplugin/` on Vim and `~/.config/nvim/ftplugin/` on Neovim.
Here's why it is so important: `ftplugin/` is the correct directory to place LaTeX-specific configuration (or in general any configuration that you wish to apply only to a single file type), and this entire series is all about LaTeX-specific configuration.

### Vim's filetype plugin system
Say you've written some customizations that you want to apply only to LaTeX files, and not to any other file types.
To keep your LaTeX customizations specific to only LaTeX files, you should use Vim's *filetype plugin system*.

#### Filetype plugin basic recipe
Say you want to write a plugin that applies only to LaTeX files.
Here's what to do:
1. Add the following lines to your `vimrc`
   (these settings are enabled by default on Neovim---see `:help nvim-defaults`---but it can't hurt to place them in your `init.vim`, too):
   ```vim
   filetype on             " enable filetype detection
   filetype plugin on      " load file-specific plugins
   filetype indent on      " load file-specific indentation
   ```
   These lines enable filetype detection and filetype-specific plugins and indentation.
   To get an overview of your current filetype status, use the `:filetype` command; you want an output that reads:
   ```vim
   " With Vim's filetype-specific functionality enabled, the output looks like this
   filetype detection:ON  plugin:ON  indent:ON
   ```
  See `:help filetype` for more information on filetype plugins.

1. Create the file structure `~/.vim/ftplugin/tex.vim`.
   Your LaTeX-specific mappings and functions will go in `~/.vim/ftplugin/tex.vim`.
   That's it! Assuming you followed step 1, anything in `tex.vim` will be loaded only when editing files with the `tex` filetype (i.e. LaTeX and related files), and will not interfere with your other filetype plugins.

   Optional tip: You can also split up your `tex` customizations among multiple files (instead of having a single, cluttered `tex.vim` file).
   To do this, create the file structure `~/.vim/ftplugin/tex/*.vim`.
   Any Vimscript files inside `~/.vim/ftplugin/tex/` will then load automatically when editing files with the `tex` filetype.
   As a concrete example, you might design your `ftplugin` directory like this:
   ```sh
   # Two ways to have LaTeX-specific configuration; note the dedicated `tex` folder in the second example
   ftplugin/                  ftplugin/
   ├── tex.vim                ├── markdown.vim
   ├── markdown.vim           ├── python.vim
   └── python.vim             └── tex
                                  ├── vimtex.vim
                                  └── main.vim
   ```
   The first example uses a single `tex.vim` file inside `ftplugin`.
   In the second example, the `tex`-specific configuration is divided into two files---`vimtex.vim` might store configuration related to the VimTeX plugin and `main.tex` would store general settings for the `tex` filetype.

   
The following sections explain how loading filetype plugins works under the hood.
<!-- See `h: add-filetype-plugin` and `h: write-filetype-plugin` for further information. -->

#### Automatic filetype detection
- Vim keeps track of a file's type using the `filetype` option.
  You can view Vim's opinion of a file's `filetype` using the commands `:set filetype?` or `:echo &filetype`.

- Once you set `:filetype on` in your `vimrc` (enabled by default on Neovim), Vim automatically detects common filetypes (LaTeX included) based on the file's extension using a Vimscript file called `filetype.vim` that ships with Vim.
  You can view `filetype.vim`'s source code at the path `$VIMRUNTIME/filetype.vim` (first use `:echo $VIMRUNTIME` in Vim to determine `$VIMRUNTIME`).

#### Manual filetype detection
If Vim's default filetype detection using `filetype.vim` fails (this only happens for exotic filetypes), you can also manually configure Vim to detect the target filetype.
Note that manual detection of exotic filetypes is not needed for this tutorial (Vim detects LaTeX files without any configuration on your part), so feel free to skip ahead.
But if you're curious, here's an example using LilyPond files, which by convention have the extension `.ly`.
([LilyPond](https://lilypond.org/) is a free and open-source text-based system for elegantly typesetting musical notation; as an analogy, LilyPond is for music what LaTeX is for math.)

Here's what to do for manual filetype detection:
1. Identify the extension(s) you expect for the target filetype, e.g. `.ly` for LilyPond.

1. Make up some reasonable value that Vim's `filetype` variable should take for the target filetype.
   This can match the extension, but doesn't have to.
   For LilyPond files I use `filetype=lilypond`.

1. Create the file `~/.vim/ftdetect/lilypond.vim` (the file name, in this case `lilypond.vim`, can technically be anything ending in `.vim`, but by convention should match the value of `filetype`).
   Inside the file add the single line
   ```
   autocommand BufNewFile,BufRead *.ly set filetype=lilypond
   ```
   Of course replace `.ly` with your target extension and `lilypond` with the value of `filetype` you chose in step 2.
   
#### How Vim loads filetype plugins
The relevant documentation lives at `:help filetype` and `:help ftplugin`, but is rather long.
For our purposes:

- When you open a file with Vim, assuming you have set `:filetype on`, Vim tries to determine the file's type by cross-checking the file's extension against a set of extensions found in `$VIMRUNTIME/filetype.vim`.
  Generally this method works out of the box (`filetype.vim` is over 2300 lines and covers the majority of common files).
  If the file's type is not detected from extension, Vim attempts to guess the file type based on file contents using `$VIMRUNTIME/scripts.vim` (reference: `:help filetype`).
  If both `$VIMRUNTIME/filetype.vim` and `$VIMRUNTIME/scripts.vim` fail, Vim checks the contents of `ftdetect` directories in your `runtimepath`, as described in the section [Manual filetype detection](#manual-filetype-detection) a few paragraphs above.

- If Vim successfully detects a file's type, it sets the value of the `filetype` option to indicate the file type.
  Often, but not always, the value of `filetype` matches the file's conventional extension; for LaTeX this value is `filetype=tex`.
  You can check the current value of `filetype` with `echo &filetype` or `:set filetype?`.

- After the `filetype` option is set, Vim checks the contents of your `~/.vim/ftplugin` directory, if you have one.
  If Vim finds either...

  - a file `ftplugin/{filetype}.vim` (e.g. `filetype/tex.vim` for `filetype=tex`), then Vim loads the contents of `{filetype}.vim`, or

  - a directory `ftplugin/{filetype}` (e.g. `ftplugin/tex` for the `filetype=tex`), then Vim loads all `.vim` files inside the `{filetype}` directory.

As a best practice, keep filetype-specific settings in dedicated `{filetype}.vim` files inside `ftplugin/`.
Think of `ftplugin/{filetype.vim}` as a `vimrc` for that file type only.
Keep your `init.vim` for global settings you want to apply to all files.



## Key mappings
Vim key mappings allow you to customize the meaning of typed keys,
and I would count them among the fundamental Vim configuration tools.
In the context of this series, key mappings are mostly used to define shortcuts for calling commands and functions that would be tedious to type out in full (similar to aliases in, say, the Bash shell).

### Writing key mappings
The `Key mapping` chapter in the documentation file `map.txt`, which you can access with `:help key-mapping`, contains the official documentation of key mappings.
I will summarize here what I deem necessary for understanding the key mappings used in this series. 

The most general syntax for defining a key mapping is
```vim
:map {lhs} {rhs}
```
Here is what's involved in the mapping definition:
- `{lhs}`: A (generally short and memorable) key combination you wish to map
- `{rhs}`: A (generally longer, tedious-to-manually-type) key combination you want the short, memorable `{lhs}` to trigger.
- The Vim mode you want the mapping to apply in, which you can control by replacing `:map` with `:nmap` (normal mode), `:vmap` (visual mode), `:imap` (insert mode), or a host of other related commands, listed in `:help :map-commands`.

The command `:map {lhs} {rhs}` then maps the key sequence `{lhs}` to the key sequence `{rhs}` in the Vim mode in which the mapping applies.

You probably already have some key mappings in your `vimrc` or `init.vim`.

#### Map modes
The documentation at `:help map-modes` gives an overview of the various map commands (`nmap`, `imap`, `map`, etc...) and the Vim modes in which they apply.
For your convenience, here is table summarizing Vim's command and map modes, taken from `:help map-table`:

  |       | normal | insert | command | visual | select | operator-pending | terminal | lang-arg |
  | -----------  |------|-----|-----|-----|-----|-----|------|------| 
  | `[nore]map`  | yes  |  -  |  -  | yes | yes | yes |  -   |  -   |
  | `n[nore]map` | yes  |  -  |  -  |  -  |  -  |  -  |  -   |  -   |
  | `[nore]map!` |  -   | yes | yes |  -  |  -  |  -  |  -   |  -   |
  | `i[nore]map` |  -   | yes |  -  |  -  |  -  |  -  |  -   |  -   |
  | `c[nore]map` |  -   |  -  | yes |  -  |  -  |  -  |  -   |  -   |
  | `v[nore]map` |  -   |  -  |  -  | yes | yes |  -  |  -   |  -   |
  | `x[nore]map` |  -   |  -  |  -  | yes |  -  |  -  |  -   |  -   |
  | `s[nore]map` |  -   |  -  |  -  |  -  | yes |  -  |  -   |  -   |
  | `o[nore]map` |  -   |  -  |  -  |  -  |  -  | yes |  -   |  -   |
  | `t[nore]map` |  -   |  -  |  -  |  -  |  -  |  -  | yes  |  -   |
  | `l[nore]map` |  -   | yes | yes |  -  |  -  |  -  |  -   | yes  |

This series uses mostly `map`, `nmap`, `omap`, `xmap`, `vmap`, and their `noremap` equivalents.

#### Map arguments
What Vim calls map arguments are special keywords that allow you to customize a key mapping's functionality;
the official documentation may be found at `:help map-arguments`.
Vim defines for 6 map arguments,
`<buffer>`, `<nowait>`, `<silent>`, `<script>`, `<expr>` and `<unique>`, which may be used in any order.
They must appear right after the `:map` command, the mappings `{lhs}`.
Here is a short summary, which you can reference later, as needed:

- `<silent>` stops a mapping from producing output on Vim's command line.
  It is often used in practice to avoid annoying `"Press ENTER or type command to continue"` prompts.


- If the `<buffer>` keyword is included in a key mapping, the mapping will apply only to the Vim buffer for which the mapping was loaded or defined.
  Example use case: filetype plugins implementing filetype-specific functionality, in which you want a mapping to apply only to the buffer holding the target filetype. 

- A mapping using `<unique>` will fail if a mapping with the same `{lhs}` already exists.
  Use `<unique>` when you want to be extra careful that a mapping won't overwrite an existing mapping with the same `{lhs}`.

- `<script>` is used to define a new mapping that only remaps characters in the `{rhs}` using mappings that were defined local to a script, starting with `<SID>`.
  This keyword is used in practice when defining mappings that call script-local functions, and is not something you would have to worry about outside of that context.
  <!-- **TODO** ref section with script-local mappings. -->

- The `<nowait>` and `<expr>` keywords are not needed for this series; see `:help map-nowait` and `:help map-expression` if interested.


**Useful: the `<Cmd>` keyword**

Vim defines one more keyword: `<Cmd>`.
You can use `<Cmd>` mappings to execute Vim commands directly in the current mode (without using `:` to enter Vim's command mode).
Using `<Cmd>` avoids unnecessary mode changes and associated autommand events, improves performance, and is generally the best way to run Vim commands.
The official documentation lives at `:help map-<cmd>`; here are some examples for reference
```
noremap e <Cmd>echo "Hello world!"<CR>
```
**TODO** do the compilation and update thing.

#### Leader key
- See `:help mapleader` leader key.
  Basically, `<Leader>` is an alias for the content of the `mapleader` variable.
  (See the contents of `mapleader` with `:echo mapleader`).
  Improtant (see `:help mapleader`): the value of `mapleader` is used at the time the mapping was defined.
  Changing `mapleader` after defining a mapping won't change the mapping.

  Local equivalent is `maplocalleader` and `<localleader>`

- Suggestion: `,` and `<Space>` are good prefixes for normal mode mappings

### Listing mappings and getting information
- `:help map-listing` for an explanation of the syntax used when listing mappings with e.g. `:map`, `imap`, etc...

- Super useful (tucked away at the bottom of `:help map-which-keys`): use the command `:help {key}<C-D>` to see which commands/mappings start with `{key}` (where `<C-D>` is `CTRL-D`).
  For example `:help s<C-D>` shows all commands starting with `s`.
  Type a command you wish to get help on and press enter to go to the corresponding help page.

- See `:help <>` for explanation of `<>` notation for special keys, e.g. `<Esc>` for the escape key or `<CR>` for the Return key.

  See also `:help keycodes` for a list of all special key codes that can be used with the `:map command`.

### Script-local mappings 
Keep the big picture in mind: (from `:help script-local`)

> When using several Vim script files, there is the danger that mappings and functions used in one script use the same name as in other scripts.
> To avoid this, they can be made local to the script.

- The point of `<SID>` is to give each function a unique "script ID" so that it won't conflict with functions with the same name in other scripts; `<SID>` is just the identification number of the script in which a script-local function is define.
  It allows Vim to find a script-local function, without the possibility that functions with the same name in other scripts would conflict with each other.

  Again: `<SID>` is the unique identifier of a script in which a function was defined.

**TODO**: clean up language
- `<Plug>` doesn't have special meaning beyond the letters themselves.
  It just understood to mean... hmmm IDK.
  You use it "for mappings the user might want to map a key sequence to".
  It's an in-between step.
  Kind of API-like.
  The plugin author maps some complicated expression for function call to `<Plug>XYZ`, and then the user, to access the complicated stuff, has to map (using `map` and not `noremap!`) a familiar sequence to `<Plug>XYZ`.

  `<Plug>` is a buffer.
  The hold point is that a user would never *accidentally* type `<Plug>`.
  It avoids the scenario in which a plugin author maps idk `gg` or something to a function call and the user wouldn't expect it, and trigger the mapping by accident in everyday use.
  So the plugin author maps function call to a `<Plug>` mapping and indicates this in the plugin documentation.
  Then the user has a very low risk of triggering the mapping in unwanted scenarios, since who would every type `<Plug>` in everyday usage?

- From `:help using-<Plug>`, the suggested naming convention to make it VERY unlikely that mappings from different scripts interfere with each other is
  
  > `<Plug>{Script-abbreviation}{Map-description};`

  Only the first letter of the script name and the first letter of the map description should be uppercase, to clearly distinguish the two.
  A semicolon is added to the end intentionally.
  The semicolon is excessive for me.

- `scriptnames` show the names of all sourced scripts in order of increasing `<SNR>` number

#### Recipe: mapping to script-local functions
- Make functions script-local `function s:{function-name}()`

- Then:
  ```vim
  function! s:TexCompile()
    " function body would go here
  endfunction

  " define key map here
  nmap <leader>c <Plug>TexCompile
  nnoremap <script> <Plug>TexCompile <SID>TexCompile
  nnoremap <SID>TexCompile :call <SID>TexCompile()<CR>
  ```
  (To fully understand what is happens, you should understand the general difference between `map` and `noremap`.)

  Note the use of:
  - `nmap` in `nmap <leader>c <Plug>TexCompile`, since we want to remap `<leader>c` to `<Plug>TexCompile` (we want `<leader>c` to trigger the same thing that `<Plug>TexCompile` is mapped to one line below.)


  - `nnoremap <script>` in `<nnoremap> <script> <Plug>TexCompile <SID>TexCompile`.

    First what this does: `noremap <script> {lhs} <SID>{rhs}` will only remap `<SID>{rhs}` to mappings defined in the script with script ID `<SID>`.

    Using `noremap <script>` really means "use `remap` if the mapping's RHS occurs in the script with script ID `<SID>`, and use `noremap` otherwise".

    This is a peculiarity of the `<script>` keyword and is described in `:map-script`, if not in perfectly clear language.

  - `nnoremap` in `nnoremap <SID>TexCompile :call <SID>TexCompile()<CR>`.
    This ensures the mapping's RHS, i.e. `:call <SID>TexCompile()<CR>`, is executed verbatim.

#### Understanding what could go wrong if you don't follow best practices
It helps to understand the consequences (which often aren't terribly severe), so you can make an informed decision for yourself.
Often, regular users writing plugins for themselves won't find compelling reasons to take all of the safety measures listed above, because the extra bother outweights the potential benefits.

- If you don't use `<unique>` with mappings, any existing mapping with the same `{lhs}` will be overwritten.
  If you do use `<unique>`, the new mapping will fail with an error message, so that you can debug the problem.

  If writing mappings for your own use that you know you want to be the way they are, there is no compelling reason to use use `<unique>`.
  You would use `<unique>` as a plugin author to prevent the possibility that users of your plugin, who won't be looking at its source code, won't have their mappings overwritten.

  I rarely see `<unique>` out in the wild, although you can find it in Tim Pope's `vim-fugitive` in `autoload/fugitive.vim`

- If you don't use `<SID>`, there is a possibility that functions with the same name, but defined in different scripts, will conflict.
  One will end up overwriting the other and you will get confusing results.

  Again, this is relevant more for plugin authors than for users.
  If you're sure a function name doesn't occur anywhere else in your Vim directory (which is reasonable if you prefix your function name with a short abbreviation of your script and have your external plugins under control), you'll be fine not using `<SID>`

  `<SID>`: ensures multiple instances of the same function name in different scripts don't conflict

- `<Plug>`: ensures multiple instances of a mapping LHS in different scripts don't conflict.


## Writing Vimscript functions
### About this section
Nothing in this section is original---everything comes from the Vim documentation section `eval.txt`, which covers everything a typical user would need to know about Vimscript expressions.
But `eval.txt` is over 12000 lines and not terribly inviting to beginners, so I am listing here the information I have subjectively found most relevant for a typical user getting started with writing Vimscript functions.

Please keep in mind: this article is *not* an attempt to replace the Vim documentation, nor is it a comprehensive Vimscript tutorial.
Rather, it is a selection of the Vimscript needed to understand the content of this series, presented in a way that should hopefully be easier for a new user to understand than tackling `:help eval.txt` directly, together with references of exactly where in the Vim docs to find more information.
My goal is to make it easier for you to get started and avoid some common pitfalls; you can then return to `eval.txt` once you find your footing.

Note on documentation: `:help usr_41.txt` provides a summary of Vimscript.
There is some overlap between `usr_41.txt` and `eval.txt`.
In my experience the coverage of functions in `eval.txt` is more comprehensive but less easy to read, like a `man` page, while the coverage of functions in  `usr_41.txt` is an incomplete summary of the material from `eval.txt`.

### Function definition syntax
A quick Vim vocabulary lesson:
- *Vim functions* (a better name would be *built-in functions*) are functions built-in to Vim, like `expand()` and `append()`; built-in function start with lowercase letters.
  You can find a full list at `:help vim-function`, which is 7500+ lines long.

- *User functions* are custom Vimscript functions written by a user in their personal plugins or Vim config; their usage is documented at `:help user-function`.

In this series we'll be interested in user functions.
From `:help E124`, the name of a user-defined function...

  > ... must be made of alphanumeric characters and `_`, and must start with either a capital letter or `s:` [...] to avoid confusion with built-in functions.

The Vim documentation makes the capital letter requirement for user-defined functions sound more severe than it is---starting functions with capital letters, to the best of my knowledge, is just a sensible best practice to avoid conflicts with built-in Vim functions, which are always lowercase.
Your user functions will work fine if they start with a lower-case letter, as long as they don't conflict with existing Vim functions.
(For example, Tim Pope's excellent [`vim-commentary`](https://github.com/tpope/vim-commentary) and [`vim-surround`](https://github.com/tpope/vim-surround) plugins include some lowercase function names.) But by using uppercase function names, you *ensure* your functions won't conflict with built-in Vim functions.
(Note that a special class of functions called *autoload functions* often intentionally start with lowercase letters, but autoload functions use a special syntax to avoid conflict with built-in Vim functions.)

The general syntax for defining Vimscript functions, defined at `:help E124`, is
```vim
function[!] {name}([arguments]) [range] [abort] [dict] [closure]
  " function body
endfunction
```
Anything in square brackets is optional.
Most Vimscript functions used in this series follow the following syntax:
```vim
function! {name}([arguments]) abort
  " function body
endfunction
```
Here is an explanation of what each piece means:
- Adding `!` after a `function` declaration will overwrite any pre-existing functions with the same name; see `:help E127` for reference.
  This is common practice to ensure a function is reloaded whenever its parent Vimscript file is re-sourced, but will also override any functions with the same name elsewhere in your Vim configuration.

- Appending `abort` to a function definition stops function execution immediately if an error occurs during function execution (as opposed to attempting to complete the function in spite of the error).
  See `:help :function-abort` for details.
  You can also read about the optional `range`, `dict`, and `closure` keywords at `:help :func-range`, `:help :func-dict`, `:help :func-closure`, respectively, but we won't need them in this series.

- Function arguments are placed between parentheses, separated by commas, and are accessed from within the function by prepending `a:` (for "argument").
  To give you a feel for the syntax:
  ```vim
  " A function without arguments
  function MyFunction()
    echo "I don't have any arguments!"
  endfunction

  " A function with two arguments
  function MyFunction(arg1, arg2)
    echo "I have two arguments!"
    echo "Argument 1: " . a:arg1
    echo "Argument 2: " . a:arg2
    " (. is the string concatenation operator)
  endfunction
  ```
  See `:help function-argument` for documentation of how function arguments work and how to use them.

You can use the `:function` command to list all loaded user functions (expect a long list if you use plugins); consult `:help :function` for more on listing functions and finding where they were defined.

#### Tip: Best practice for naming functions
As suggested in the `PACKAGING` section of `:help 41.10`, prepend a unique, memorable string before all related functions in a Vimscript file, for example an abbreviation of the script name.
In this series, for LaTeX-related functions, we use a `Tex` prefix, as in
```vim
function TexCompile
  " function body
endfunction

function TexForwardShow
  " function body
endfunction

" and so on...
```
Prepending a short, memorable string to related functions keeps your Vimscript more organized and also makes it less likely that function names in different scripts will conflict.
If you had `Compile` functions for multiple file types, using a short prefix, such as `TexCompile` and `JavaCompile`, avoids the problem of conflicting `Compile` functions in two separate scripts.

#### Note: Another way of defining functions
When defining Vimscript functions you can use either of the following:
```vim
" Overrides any existing instance of `MyFunction` currently in memory
function! MyFunction()
  " function body
endfunction

" Loads `MyFunction` only if there are no existing instance currently in memory
if !exists("MyFunction")
  function MyFunction()
    " function body
  endfunction
endif

```
A filetype plugin is sourced every time a file of the target file type is opened.
The above techniques are two ways to make sure functions in filetype plugins are not loaded twice; the second preserves the existing definition and the first overwrites it.
The first option is more concise and readable, while the second is probably slightly more efficient, since evaluating an `if` statement is faster that overwriting and reloading a function from scratch.
But on modern hardware it is unlikely you would notice any difference in speed between the two.

### Script-local functions
Script-local functions, as the name suggests, have a scope local to the script in which they are defined.
You declare script-local functions by prepending `s:` to the function name, and they are used to avoid cluttering the global function namespace and to prevent naming conflicts across scripts.

#### Scope of script-local functions
From `:help local-function`, a script-local function can be called from the following scopes:

| if called from... | the function is accessible... |
| ----------------------------- | ----- |
| Vimscript and from within Vimscript functions | only in the parent script it was defined in |
| an autocommand defined in the parent script | anywhere |
| a user command defined in the parent script | anywhere |
| a key mapping | anywhere\* |

\* assuming you use the `<SID>` (script ID) mapping syntax, explained a few paragraphs below in the section [Calling script-local functions using SID key mappings](#calling-script-local-functions-using-sid-key-mappings).

#### Why use script-local functions?
Vimscript functions have two possible scopes: global and script-local (see `:help local-function`).
The Vim documentation recommends using script-local functions in all user-defined plugins to avoid conflicts in which functions in two different scripts use the same name.
Here is what the documentation at `:help local-function` has to say:

> If two scripts both defined global functions called, say, `function SomeFunctionName`, the names would conflict, because the functions are global.
One would overwrite the other, leading to confusion.
Meanwhile, if the scripts both used `function s:SomeFunctionName`, no problems would occur because the functions are script-local.

Lesson: using script-local functions avoids name conflict with functions in other scripts.
Although the risk of name overlap is often small, I will focus on script-local functions in this article.

Note that using script-local functions is not a hard and fast rule.
If you don't want to go through the bother of script-local functions and are certain your function names won't conflict with other scripts or plugins---especially if you don't intend to distribute your plugin to others---you don't need to make every function script-local.
Even well-known filetype plugins from reputable authors can include global functions, such as `MarkdownFold` and `MarkdownFoldText` in Tim Pope's [`vim-markdown`](https://github.com/tpope/vim-markdown), and everything works just fine.

#### Calling script-local functions using SID key mappings
In Vimscript, defining key mappings that call script-local functions is a three-step process:
1. Map the key combination you will actually use to call the function to a `<Plug>` mapping.
1. Map the `<Plug>` mapping to a `<SID>` (script ID) mapping.
1. Use the `<SID>` mapping to call the function.

The goal here is to make script-local functions usable outside of the script in which they were written, but in a way that prevents conflict with mappings and functions in other plugins.
Vim makes this possible with the `<SID>` keyword, which stands for script ID and uniquely identifies the script in which a script-local function was originally defined.

Following is a concrete example of this three-step process, adapted from the official documentation;
you can see the original source in the `PIECES` section of `:help write-plugin`.
Suppose you wanted to use the key sequence `,c` in normal mode to call a script-local function called `TexCompile` defined in, say, `ftplugin/tex.vim`.
Here is the code that would achieve this:
  ```vim
  " In the file ftplugin/tex.vim (for example), define...

  function! s:TexCompile()
    " implement compilation functionality here
  endfunction

  " Define key map here
  nmap ,c <Plug>TexCompile
  nnoremap <script> <Plug>TexCompile <SID>TexCompile
  nnoremap <SID>TexCompile :call <SID>TexCompile()<CR>
  ```
  You could then use `,c` in normal mode to call the `s:TexCompile` function from *any* file with the `tex` filetype.

Here's an explanation of what the above Vimscript does:
- `nmap ,c <Plug>TexCompile` maps the key combination `,c` to the literal string `<Plug>TexCompile` (in normal mode because of `nmap`).
  Appending `<Plug>` is conventional in this context, but note that `<Plug>` is simply a string of characters just like `TexCompile`.

- `nnoremap <script> <Plug>TexCompile <SID>TexCompile` maps the string `<Plug>TexCompile` to `<SID>Compile`.

- The final line maps `<SID>Compile` to the command `:call <SID>TexCompile()<CR>`, which calls the `TexCompile()` function (`<CR>` represents the enter key).
  Using `<SID>` before the function name, as in `<SID>TexCompile()`, allows Vim to identify the script ID of the script the function was originally defined in, which makes it possible for Vim to find and execute the function even when the mapping the calls it is used outside the original script.
  You can read more about this admittedly convoluted process at `:help <SID>`.

  It's important that `nmap ,c <Plug>TexCompile` uses `nmap` and not `nnoremap`, since it is *intended* that `<Plug>TexCompile` maps to `<SID>Compile`.
  Using `noremap ,c <Plug>TexCompile` (instead of `nmap`) would make `,c` the equivalent of literally typing the key sequence `<Plug>TexCompile`.

In summary, `,c` maps to `<Plug>TexCompile`, which maps to `<SID>TexCompile`, which calls the `TexCompile` function.
Kind of a bother, right? Oh well, consider it a peculiarity of Vim.
And, if followed, this technique ensure functions from different scripts won't conflict, which is important for maintaining a healthy plugin ecosystem.

Note that, in principle, the `<SID>` and `<Plug>` mappings and the function name could all be different! Both of the following would let you use `,c` to call a script-local `TexCompile()` function:
```vim
nmap ,c <Plug>TexCompile
nnoremap <script> <Plug>TexCompile <SID>TexCompile
nnoremap <SID>TexCompile :call <SID>TexCompile()<CR>

nmap ,c <Plug>ABC
nnoremap <script> <Plug>ABC <SID>XYZ
nnoremap <SID>XYZ :call <SID>TexCompile()<CR>
```
But it is conventional to use similar names for the `<Plug>` mapping, `<SID` mapping, and function definition.

### Autoload functions
I briefly cover autoload functions here only for the sake of completeness.
You probably won't use them for your own purposes, but the VimTeX plugin makes heavy use of autoload functions, so you might run into them when browsing the VimTeX source code.

Summarizing somewhat, autoload functions are essentially an optimization to slightly lower Vim's start-up time---instead of Vim reading and loading them into memory during initial start-up, like regular functions, Vim will load autoload functions only when they are first called.
On modern hardware, the resulting decrease in start-up time will be noticeable only for a large plugin with hundreds of functions, like VimTeX.

Here is the basic workflow for using autoload functions:

- In an `autoload/` directory somewhere in your Vim `runtimepath`, create a Vimscript file, for example `my_function_script.vim`.

- Inside `autoload/my_function_script.vim`, define a function with the syntax
  ```
  function my_function_script#function_name()
    " function body
  endfunction
  ```
  The general naming syntax is `{filename}#{function-name}`, where
  `{filename}` must exactly match the name of the Vimscript file within which the function is defined.
  When autoloading functions, it is conventional that `function-name` starts with lowercase characters.

- When needed, call the function using `call my_function_script#function_name()`.
  
  Here is what happens: Vim recognizes the `{filename}#{function-name}` syntax, realizes the function is an autoload function, and searches all `autoload` directories in your Vim `runtimepath` for files name `filename`, then within these files searchs for functions named `function_name`.
  If a match is found, a function is loaded into memory, can be called by the user, and should be visible with `:function`.

You can find official documentation of autoload functions at `:help autoload-functions`, and 

<!-- **Variables** -->
<!-- - For declaring internal variables, see `:help internal-variables` -->
<!-- - `:help variable-scope` -->
<!-- The period is the Vimscript string concatenation operator; see `:help expr5` for the official documentation. -->


