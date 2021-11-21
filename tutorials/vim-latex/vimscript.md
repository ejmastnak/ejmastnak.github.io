---
title: Vimscript Theory \| Setting Up Vim for LaTeX Part 1
---
# Vimscript Theory for Filetype-Specific Workflows

## About the series
This is part one in a [four-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents. This article provides a theoretical background for use of Vimscript in filetype-specific workflows. Feel free to skip to [part two]({% link tutorials/vim-latex/compilation.md %}) if you are familiar with Vimscript or find theory boring, and return later to brush up on anything you might have skipped.

## Contents of this article
<!-- vim-markdown-toc Marked -->

* [How to read this article](#how-to-read-this-article)
* [General considerations for file-specific Vim plugins](#general-considerations-for-file-specific-vim-plugins)
  * [What is a plugin?](#what-is-a-plugin?)
    * [Runtimepath: where Vim looks for files to load](#runtimepath:-where-vim-looks-for-files-to-load)
  * [Filetype plugins](#filetype-plugins)
    * [Filetype plugin basic recipe](#filetype-plugin-basic-recipe)
    * [Automatic filetype detection](#automatic-filetype-detection)
    * [Manual filetype detection](#manual-filetype-detection)
    * [How Vim loads filetype plugins](#how-vim-loads-filetype-plugins)
* [Writing Vimscript functions](#writing-vimscript-functions)
  * [How to read this section](#how-to-read-this-section)
  * [Function definition syntax](#function-definition-syntax)
  * [Script-local functions](#script-local-functions)
    * [Why to use script-local functions](#why-to-use-script-local-functions)
    * [Calling script-local functions using \<SID\> key mappings](#calling-script-local-functions-using-\<sid\>-key-mappings)
  * [Mappings](#mappings)
* [Notes: mapping](#notes:-mapping)
  * [Map arguments](#map-arguments)
  * [Script-local mappings](#script-local-mappings)
  * [Recipe: mapping to script-local functions](#recipe:-mapping-to-script-local-functions)
  * [Understanding what could go wrong if you don't follow best practices](#understanding-what-could-go-wrong-if-you-don't-follow-best-practices)
* [Plugin best practices](#plugin-best-practices)
  * [Autoload functions](#autoload-functions)

<!-- vim-markdown-toc -->

## How to read this article
This article is long. You don't have to read everything---I suggest skimming through on a first reading, remembering this article exists, and then referring back to it, if desired, for a theoretical understanding of the Vimscript functions and key mappings used later in the series.

For whom this article is written: not a comprehensive tutorial, blah blah, just a coherent explanation of Vimscript basics, which many Vim users never learn and just hack together, but probably would be happy to see if it were put together in one place.

By the way, nothing in this particular article is LaTeX-specific and would generalize perfectly to Vim workflows completely unrelated to LaTeX.

## General considerations for file-specific Vim plugins

### What is a plugin?
A *plugin*, as defined in `:help plugin`, is the familiar name for a Vimscript file (generally a `.vim` file) that is loaded when you start Vim. If you have every created a `vimrc` or `init.vim` file, you have technically written a Vim plugin. Just like your `vimrc`, a plugin's purpose is to extend Vim's default functionality to meet your personal needs.

A *package*, as defined in `:help packages`, is a set of Vimscript files. To be pedantic, what most people (myself included) refer to in everyday usage as a Vim plugin is technically a package. That's irrelevant; the point is that plugins and packages are just Vimscript files used to extend Vim's default functionality, and, if you have ever written a `vimrc` or `init.vim`, it is within your means to write more advanced plugins, too.

#### Runtimepath: where Vim looks for files to load
If you have ever wondered which files Vim loads at startup, the answer is the files in your *runtimepath*. Your Vim runtimepath is a list of directories, both in your home directory and system-wide, that Vim searches for files to load at runtime, i.e. when opening Vim. Below is a list of some directories on Vim's default runtimepath, taken from `:help runtimepath`---you will probably recognize some of them from your own Vim setup.

> | Directory or File | Description |
> | ----------------- | ----------- |
> | `filetype.vim` |	filetypes by file name |
> | `autoload` |	automatically loaded scripts | 
> | `colors/` | color scheme files             | 
> | `compiler/` | compiler files               | 
> | `doc/` | documentation                     | 
> | `ftplugin/` | filetype plugins             | 
> | `indent/` | indent scripts                 | 
> | `pack/` | packages                         | 
> | `spell/` | spell checking files            | 
> | `syntax/` | syntax files                   | 

You can view your current runtimepath with `:echo &runtimepath`.
If you want a plugin to load automatically when you open Vim, you must place the plugin in an appropriate location in your runtimepath. The filetype plugins covered in this tutorial should be placed in your `~/.vim` folder's `ftplugin/` directory. (For orientation, for example, customizations to your indentation settings should go in `~/.vim/indent/` and customizations to your colorscheme in `~/.vim/colors/`. This is beyond the scope of this article; see `:help runtimepath` for more.)

### Filetype plugins
Say you've written some customizations that you want to apply only to LaTeX files, and not to any other file types. To keep your LaTeX customizations local to only LaTeX files, you should use Vim's *filetype plugin system*.

#### Filetype plugin basic recipe
Say you want to write a plugin that applies only to LaTeX files. Here's what to do:
1. Add the following lines to your `vimrc`
   ```
   filetype on             " enable filetype detection
   filetype plugin on      " load file-specific plugins
   filetype indent on      " load file-specific indentation
   ```
   These lines enable filetype detection and filetype-specific plugins and indentation; see `:help filetype` for more information. To get an overview of your current filetype status, use the `:filetype` command; you want an output that reads:
   ```
   filetype detection:ON  plugin:ON  indent:ON
   ```

1. Create the file structure `~/.vim/ftplugin/tex.vim`. Your `tex` specific mappings and functions will go in `~/.vim/ftplugin/tex.vim`. That's it! Anything in `tex.vim` will be loaded only when editing files with the `tex` filetype, and will not interfere with your `vimrc` or other filetype plugins.

   You can also split up your `tex` customizations among multiple files (instead of having a single, cluttered `tex.vim` file). To do this, create the file structure `~/.vim/ftplugin/tex/*.vim`. Any Vimscript files inside `~/.vim/ftplugin/tex/` will load automatically when editing files with the `tex` filetype.
   
The following sections explain what happens under the hood.
<!-- See `h: add-filetype-plugin` and `h: write-filetype-plugin` for further information. -->

#### Automatic filetype detection
- Vim keeps track of a file's filetype using the `filetype` variable. You can view a file's `filetype`, according to Vim, with the commands `:echo &filetype` or `:set filetype?`.

- Once you set `:filetype on`, Vim automatically detects common filetypes (LaTeX included) based on the file's extension using a Vimscript file called `filetype.vim` that ships with Vim. You can view the source code at the path `$VIMRUNTIME/filetype.vim` (use `:echo $VIMRUNTIME` in Vim to determine `$VIMRUNTIME`).


#### Manual filetype detection
Manual detection of exotic filetypes is not needed for this tutorial---feel free to skip ahead. If you're curious, here's an example using LilyPond files, which by convention have the extension `.ly`. (LilyPond is a FOSS text-based system for elegantly typesetting musical notation; as an analogy, LilyPond is for music what LaTeX is for math.)

Here's what to do for manual filetype detection:
1. Identify the extension(s) you expect for the target filetype, e.g. `.ly` for LilyPond. 

1. Make up some reasonable value that Vim's `filetype` variable should take for the target filetype. This can match the extension, but doesn't have to. For LilyPond files I use `filetype=lilypond`.

1. Create the file `~/.vim/ftdetect/lilypond.vim` (the file name, in this case `lilypond.vim`, can technically be anything ending in `.vim`, but by convention should match the value of `filetype`). Inside the file add the single line
   ```
   autocommand BufNewFile,BufRead *.ly set filetype=lilypond
   ```
   Of course replace `.ly` with your target extension and `lilypond` with the value of `filetype` you chose in step 2.
   
#### How Vim loads filetype plugins
The relevant documentation lives at `:help filetype` and `:help ftplugin`, but is rather long. For our purposes:

- When you open a file with Vim, assuming you have set `:filetype on`, Vim tries to determine the file's type by cross-checking the file's extension againt a set of extensions found in `$VIMRUNTIME/filetype.vim`. Generally this method works out of the box (`filetype.vim` is over 2300 lines and covers the majority of common files). If the file's type is not detected from extension, Vim attempts to guess the file type based on file contents using `$VIMRUNTIME/scripts.vim` (reference: `:help filetype`). If both `$VIMRUNTIME/filetype.vim` and `$VIMRUNTIME/scripts.vim` fail, Vim checks the contents of `ftdetect` directories in your runtimepath, as described in the [**Manual filetype detection**](#manual-filetype-detection) section above.

- If Vim successfully detects a file's type, it sets the value of the `filetype` option to indicate the file type. Often, but not always, the value of `filetype` matches the file's conventional extension; for LaTeX this value is `filetype=tex`. You can check the current value of `filetype` with `echo &filetype` or `:set filetype?`.

- After the `filetype` option is set, Vim checks the contents of your `~/.vim/ftplugin` directory, if you have one. If Vim finds either...

  - a file `ftplugin/{filetype}.vim` (e.g. `filetype/tex.vim` for `filetype=tex`), then Vim loads the contents of `{filetype}.vim`, or

  - a directory `ftplugin/{filetype}` (e.g. `ftplugin/tex` for the `filetype=tex`), then Vim loads all `.vim` files inside the `{filetype}` directory.

As a best practice, keep filetype-specific settings in dedicated `{filetype}.vim` files inside `ftplugin/`. Think of `ftplugin/{filetype.vim}` as a `vimrc` for that file type only. Keep your `init.vim` for global settings you want to apply to all files.


## Writing Vimscript functions
### How to read this section
*Everything in this article comes from the help document `eval.txt`*, which covers everything a typical user would need to know about Vimscript expressions. You can access it with `:help eval.txt`. Since `eval.txt` is over 12000 lines and not terribly inviting to beginners, I am listing here the information I have subjectively found most relevant for a typical user getting started with writing Vimscript functions.

But please keep in mind: this article is *not* an attempt to replace the Vim documentation, nor is it a rigorous Vimscript tutorial. It is a summary of the basic Vimscript rules presented in a way that should hopefully be easier for a new user to understand than tackling `:help eval.txt` directly, together with references of exactly where in the Vim docs to find more information. My goal is to make it easier for you to get started and avoid some common pitfalls; you can then return to `eval.txt` once you find your footing.

Note on documentation: `:help usr_41.txt` provides a summary of Vimscript. There is some overlap between `usr_41.txt` and `eval.txt`. In my experience the coverage of functions in `eval.txt` is more comprehensive but less easy to read, like a `man` page, while the coverage of functions in  `usr_41.txt` is an incomplete summary of the material from `eval.txt`.

### Function definition syntax
A quick Vim vocabulary lesson:
- *Vim functions* are functions built-in to Vim, like `expand()` and `append()`; built-in function start with lowercase letters. You can find a full list at `:help vim-function`, which is 7500+ lines long.

- *User functions* are custom functions written by a user; their usage is documented at `:help user-function`.

In this series we'll be interested in user functions. From `:help E124`, the name of a user-defined function...

  > ... must be made of alphanumeric characters and `_`, and must start with either a capital letter or `s:`

  <!-- Also from the Vim docs at `:help user-function`: -->

  <!-- > [a user] function name must start with an uppercase letter, to avoid confusion with built-in functions. A good habit is to start the function name with the name of the script, e.g., `HTMLcolor()`. -->

The Vim documentation makes the capital letter requirement sound more severe than it is---capital user functions, to the best of my knowledge, are really a sensible best practice to avoid conflicts with built-in Vim functions, which are always lowercase. But your user functions will work fine if they start with a lower-case letter and don't conflict with existing Vim functions. (For example, Tim Pope's excellent [`vim-commentary`](https://github.com/tpope/vim-commentary) and [`vim-surround`](https://github.com/tpope/vim-surround) plugins include lowercase function names.) And a special class of functions called *autoload functions* often start with lowercase letters. But by using uppercase function names, you *ensure* your functions won't conflict with built-in Vim functions.

The general syntax for defining Vimscript functions, defined at `:help E124`, is
```vim
function[!] {name}([arguments]) [range] [abort] [dict] [closure]
  " function body
endfunction
```
Anything in square brackets is optional. For must use cases in this series, we will use the following:
```vim
function! {name}([arguments]) abort
  " function body
endfunction
```

-  Adding `!` after a `function` declaration will overwrite any pre-existing functions with the same name; see `:help E127` for reference. Use `!` to ensure a function is loaded if you're sure you won't be overriding a different function with the same name somewhere else in your Vim configuration.

- Appending `abort` to a function definition stops function execution immediately if an error occurs during function execution. You can read about the `range`, `dict`, and `closure` keywords at `:help :func-range`, `:help :func-dict`, `:help :func-closure`, respectively, but we won't need them in this series.

- Function arguments are placed between parentheses, separated by commas, and are accessed from within the function by prepending `a:` (for "argument"). To give you a feel for the syntax:
  ```vim
  function MyFunction()
    echo "I don't have any arguments!"
  endfunction

  function MyFunction(arg1, arg2)
    echo "I have two arguments!"
    echo "Argument 1: " . a:arg1
    echo "Argument 2: " . a:arg2
    " (. is the string concatenation operator)
  endfunction
  ```
  See `:help function-argument` for documentation of how function arguments work and how to use them.

- Use `:function` to list all loaded user functions (expect a long list if you use plugins), and see `:help :function` for more on listing functions and finding where they were defined.

**Tip: Best practice for naming functions**

As suggested in the `PACKAGING` section of `:help 41.10`, prepend a unique, memorable string before all related functions in a Vimscript file, for example an abbreviation of the script name. Later in this series, for LaTeX-related functions, we will use a `Tex` prefix, as in
```vim
function TexCompile
  " function body
endfunction

function TexForwardShow
  " function body
endfunction

" and so on...
```
Prepending a short, memorable string to related functions keeps your Vimscript more organized and also makes it less likely that function names in different scripts will conflict. If you had `Compile` functions for multiple file types, using a short prefix, such as `TexCompile` and `JavaCompile`, avoids the problem of conflicting `Compile` functions in two separate scripts.

**Tip: Another way of defining functions**

When defining Vimscript functions you can use either of the following:
```vim
if !exists("s:MyFunction")
  function s:MyFunction()
    " function body
  endfunction
endif

function! s:MyFunction()
  " function body
endfunction
```
From the `FUNCTION` section of `:help write-filetype-plugin`, a filetype plugin is sourced every time a file of the target file type is opened. The above techniques are two ways to make sure functions in a filetype plugin are not loaded twice; the first preserves the existing definition and the second overwrites it.

The second option is more concise and readable, while the first is likely more efficient, since evaluating an `if` statement is faster that overwriting and reloading a function from scratch. But on modern hardware it is unlikely you would notice a significant difference in speed between the two.



### Script-local functions

#### Why to use script-local functions
Vimscript functions have two possible scopes: global and script-local (see `:help local-function`). The Vim documentation recommends using script-local functions in user-defined plugins, for the following reason:

> If two scripts both defined global functions called, say, `function SomeFunctionName`, the names would conflict, because the functions are global. One would overwrite the other, leading to confusion. Meanwhile, if the scripts both used `function s:SomeFunctionName`, no problems would occur because the functions are script-local.

Lesson: using script-local functions avoids name conflict with functions in other scripts. Although the risk of name overlap is often small, I will focus on script-local functions in this article.

Note that using script-local functions is not a hard and fast rule. If you don't want to go through the bother of script-local functions and are certain your function names won't conflict with other scripts or plugins---especially if you don't intend to distribute your plugin to others---you don't need to make every function script-local. Even well-known filetype plugins from reputable authors can include global functions, such as `MarkdownFold` and `MarkdownFoldText` in Tim Pope's [`vim-markdown`](https://github.com/tpope/vim-markdown), and everything works just fine.

**The big picture**

To implement the functions and key maps used later in this series, you basically need to know:
- how to write a Vimscript function (described above)
- how to define a key mapping that makes the function accessible outside the script it was defined in (described below).

From `:help local-function`, a script-local function can be called from the following scopes:

| if called from... | the function is accessible... |
| ----------------------------- | ----- |
| Vimscript and from within Vimscript functions | only in the parent script it was defined in |
| an autocommand defined in the parent script | anywhere |
| a user command defined in the parent script | anywhere |
| a key mapping | anywhere\* |

\* assuming you use the `<SID>` (script ID) mapping syntax, explained below.

#### Calling script-local functions using \<SID\> key mappings
The big picture is to make script-local functions usable outside of the script in which they were written, without interfering with mappings in other plugins. Safely defining key mappings that call script-local functions requires a three-step process:
  1. Map the desired key combination, i.e. the key combo you will actually call the function with, to a `<Plug>` mapping
  2. Map the `<Plug>` mapping to a `<SID>` mapping
  3. Use the `<SID>` mapping to call the function.

Here is a hello-world style example, adapted from the official documentation in the `PIECES` section of `:help write-plugin`. Suppose you wanted to use the key sequence `,c` to call the function `TexCompile` (defined as a script-local function at, say, `ftplugin/tex.vim`) in normal mode. Here's how you would do it:
  ```vim
  " in the file ftplugin/tex.vim (for example), define...

  function! s:TexCompile()
    " implement compilation functionality here
  endfunction

  " define key map here
  nmap ,c <Plug>TexCompile
  nnoremap <script> <Plug>TexCompile <SID>TexCompile
  nnoremap <SID>TexCompile :call <SID>TexCompile()<CR>
  ```
  You could then use `,c` in normal mode to call the `s:TexCompile` function from *any* file with the `tex` filetype.

And here's an explanation of what the above Vimscript does:
- `nmap ,c <Plug>TexCompileMapping` maps the key combination `,c` to the string `<Plug>TexCompile` (in normal mode only because of `nmap`)
- which maps to `<SID>Compile`
- which maps to `:call <SID>TexCompile`. 

Note: it's important that `nmap <leader>c <Plug>TexCompile` uses `nmap` and not `nnoremap`, since it is *intended* that `<Plug>TexCompile` maps to `<SID>Compile`. Using `nmap ,c <Plug>TexCompileMapping` would make `,c` the equivalent of literally typing the key sequence `<Plug>TexCompile` in normal mode.

Kind of a bother, right? Oh well, consider it a peculiarity of Vim. And, if followed, this technique ensure functions from different scripts won't conflict, which is important for maintaining a healthy plugin ecosystem.

In principle, the `<SID>`, `<Plug>`, and function names could all be different! Both of the following work:
```vim
nmap ,c <Plug>TexCompile
nnoremap <script> <Plug>TexCompile <SID>TexCompile
nnoremap <SID>TexCompile :call <SID>TexCompile()<CR>

nmap ,c <Plug>ABC
nnoremap <script> <Plug>ABC <SID>XYZ
nnoremap <SID>XYZ :call <SID>TexCompile()<CR>
```


If you want to be REALLY conservative, the Vim docs (see `:help write-filetype-plugin`) recommend the following:
```
if !exists("g:no_plugin_maps") && !exists("g:no_tex_plugin_maps")
  if !hasmapto('<Plug>TexCompile')
    nmap <buffer> <LocalLeader>c <Plug>TexCompile
  endif
  nnoremap <buffer> <script> <Plug>TexCompile <SID>TexCompile
  nnoremap <SID>Compile  :call <SID>TexCompile()<CR>
endif
```
The variable `g:no_plugin_maps` disables mappings for all filetype plugins while `g:no_tex_plugin_maps` disables mappings specific to the `tex` filetype plugin. 
  
### Mappings
- Use the two-step `<Plug>{DescriptiveName}` method for defining mappings in plugins that others might use. The choice of `<Plug>{DescriptiveName}` should be something that would be unique (within reasonable expectations).

- Then for a useful mapping use 
  ```
  if !hasmapto("<Plug>{PlugName}", "{mapmode}") && "" == mapcheck("{mapping}","{mapmode}")
    {mode}map {mapping} <Plug>{PlugName}
  endif

  " example with <Plug>TexCompile mapped to <leader>c in normal mode
  if !hasmapto("<Plug>TexCompile", "n") && "" == mapcheck("<leader>c","n")
    nmap <leader>c <Plug>TexCompile
  endif
  ```
  Alternatively, or as an additional safety mechanism, define a variable (e.g.) `g:my_plugin_no_mappings` and to something like
  ```
  if !exists("g:my_plugin_no_mappings") || ! g:my_plugin_no_mappings
    nmap <leader>c <Plug>TexCompile
  endif
  ```
  I recommend learning from the experts: check for example the very bottom to Tim Pope's `surround.vim` or `commentary.vim`.

  - Note that these are hardcore safety mechanisms and are needed only if the plugin will be distributed to other people, to avoid overwriting their existing mappings and whatnot. You can be sloppier (or I guess less cautious) if you are writting only for yourself.
  
## Notes: mapping
- `:help mapmodes` for documentation of map modes; in practice: the meaning of `nmap`, `imap`, `map`, and so on.

- `:help script-local` for script-local mappings and functions


  The big picture: 

  > when using several Vim script files, there is the danger that mappings and functions used in one script use the same name as in other scripts.  To avoid this, they can be made local to the script.

- `:help map-listing` for an explanation of the syntax used when listing mappings with e.g. `:map`, `imap`, etc...

  From `:help map-table`:

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


- See `:help mapleader` leader key. Basically, `<Leader>` is an alias for the content of the `mapleader` variable. (See the contents of `mapleader` with `:echo mapleader`). Improtant (see `:help mapleader`): the value of `mapleader` is used at the time the mapping was defined. Changing `mapleader` after defining a mapping won't change the mapping.

  Local equivalent is `maplocalleader` and `<LocalLeader>`

- See `:help <>` for explanation of `<>` notation

- If you need multiple map commands on a single line, separate them with `|` (but don't put multiple map commands on a single line!) (see `:help map-comments` and `:help map-bar` just below).

**Suggestions**
- `,` and `<Space>` are good prefixes for normal mode mappings
- Super useful (tucked away at the bottom of `:help map-which-keys`): use the command `:help {key}<C-D>` to see which commands/mappings start with `{key}`. (where `<C-D>` is `CTRL-D`). For example `:help s<C-D>` shows all commands starting with `s`. Type command and press enter to go to the corresponding help page.

### Map arguments
Reference: `:help map-arguments`

`<buffer>`, `<nowait>`, `<silent>`, `<script>`, `<expr>` and `<unique>` can be used in any order. They must appear right after the map command, before any other arguments.

- `<silent>` stops a mapping from producing output on Vim's command line. It is often used to avoid `"Press enter to continue"` dialogs.

- `<script>` is used to define a new mapping that only remaps characters in the `{rhs}` using mappings that were defined local to a script, starting with `<SID>`.
  
  Use: "avoid that mappings from outside a script interfere", but do use other mappings defined in the script.  

  Note: `:map <script>` and `:noremap <script>` both act as `:noremap <script>`;  the `<script>` argument overrules the `:map` command to act as `noremap`. Best practice: use `:noremap <script>`, because it's clearer that remapping is (mostly) disabled.

- `<unique>`: mapping will fail if a mapping with the same `{lhs}` already exists.

- `<expr>`: in this case the mapping's `{rhs}` is interpretted as a Vimscript expression, and the result of the expression is inserted. With `<expr>` the mapping's `{lhs}` calls the Vimscript expression in the mapping's `{rhs}`. Mappins with `<expr>` are often used in insert mode to insert the output of Vimscript functions.

  Return an empty string `''` to not insert anything.

  Note: you don't use `:call` to call functions with `<expr>`, just e.g.
  ```
	:inoremap <expr> ff <SID>InsertFraction()
  ```
  Plenty more you can do with `<expr>` than is needed here---see `:help map-<expr>`.

- Use `<Cmd>` mappings to execute Vim commands directly in the current mode. Reference: `:help map-<cmd>`

  Using `<Cmd>` avoids mode changes and is the cleanest solution to running commands, instead of `<C-O>:{cmd}`. Particularly useful in insert mode to avoid `<C-O>` hacks. You do need a terminating `<CR>` though.
  ```
  noremap e <Cmd>echo "Hello world!"<CR>
  ```

### Script-local mappings 
Keep the big picture in mind: (from `:help script-local`)

> When using several Vim script files, there is the danger that mappings and functions used in one script use the same name as in other scripts. To avoid this, they can be made local to the script.

- The point of `<SID>` is to give each function a unique "script ID" so that it won't conflict with functions with the same name in other scripts; `<SID>` is just the identification number of the script in which a script-local function is define. It allows Vim to find a script-local function, without the possibility that functions with the same name in other scripts would conflict with each other.

  Again: `<SID>` is the unique identifier of a script in which a function was defined.

- `<Plug>` doesn't have special meaning beyond the letters themselves. It just understood to mean... hmmm IDK. You use it "for mappings the user might want to map a key sequence to". It's an in-between step. Kind of API-like. The plugin author maps some complicated expression for function call to `<Plug>XYZ`, and then the user, to access the complicated stuff, has to map (using `map` and not `noremap!`) a familiar sequence to `<Plug>XYZ`. 

  `<Plug>` is a buffer. The hold point is that a user would never *accidentally* type `<Plug>`. It avoids the scenario in which a plugin author maps idk `gg` or something to a function call and the user wouldn't expect it, and trigger the mapping by accident in everyday use. So the plugin author maps function call to a `<Plug>` mapping and indicates this in the plugin documentation. Then the user has a very low risk of triggering the mapping in unwanted scenarios, since who would every type `<Plug>` in everyday usage?

- From `:help using-<Plug>`, the suggested naming convention to make it VERY unlikely that mappings from different scripts interfere with each other is
  
  > `<Plug>{Script-abbreviation}{Map-description};`

  Only the first letter of the script name and the first letter of the map description should be uppercase, to clearly distinguish the two. A semicolon is added to the end intentionally. The semicolon is excessive for me.

- `scriptnames` show the names of all sourced scripts in order of increasing `<SNR>` number

### Recipe: mapping to script-local functions
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

  - `nnoremap` in `nnoremap <SID>TexCompile :call <SID>TexCompile()<CR>`. This ensures the mapping's RHS, i.e. `:call <SID>TexCompile()<CR>`, is executed verbatim.

### Understanding what could go wrong if you don't follow best practices
It helps to understand the consequences (which often aren't terribly severe), so you can make an informed decision for yourself. Often, regular users writing plugins for themselves won't find compelling reasons to take all of the safety measures listed above, because the extra bother outweights the potential benefits.

- If you don't use `<unique>` with mappings, any existing mapping with the same `{lhs}` will be overwritten. If you do use `<unique>`, the new mapping will fail with an error message, so that you can debug the problem.

  If writing mappings for your own use that you know you want to be the way they are, there is no compelling reason to use use `<unique>`. You would use `<unique>` as a plugin author to prevent the possibility that users of your plugin, who won't be looking at its source code, won't have their mappings overwritten. 

  I rarely see `<unique>` out in the wild, although you can find it in Tim Pope's `vim-fugitive` in `autoload/fugitive.vim`

- If you don't use `<SID>`, there is a possibility that functions with the same name, but defined in different scripts, will conflict. One will end up overwriting the other and you will get confusing results. 

  Again, this is relevant more for plugin authors than for users. If you're sure a function name doesn't occur anywhere else in your Vim directory (which is reasonable if you prefix your function name with a short abbreviation of your script and have your external plugins under control), you'll be fine not using `<SID>`

  `<SID>`: ensures multiple instances of the same function name in different scripts don't conflict


- `<Plug>`: ensures multiple instances of a mapping LHS in different scripts don't conflict.


## Plugin best practices
This section lists some of the best practices suggested in `:help write-plugin` and `:help write-filetype-plugin`.

- Use a unique global variable, conventionally something like `g:loaded_myplugin`, as a safety mechanism to prevent loading a user-defined plugin twice. Then include the following Vimscript at the *very start* of your plugin (before implementing any functionality):
  ```vim
  if exists("g:loaded_myplugin")  " if `g:loaded_myplugin` exists, the plugin was already loaded
    finish  " exit immediately
  endif
  let g:loaded_myplugin = 1       " record that plugin has been loaded
  ```
  This technique, besides avoiding problems with twice-defined autocommands and functions, allows users to disable loading the plugin, if desired---a user who wouldn't want to use the plugin would set `g:loaded_myplugin = 1` (or any other value, as long as they create the variable) somewhere in their `vimrc`. The safety mechanism above would immediately `finish` and exit the plugin upon finding that `g:loaded_myplugin` was already defined. Reference: the `NOT LOADING` section of `:help write-plugin`.

- Use `:setlocal` instead of `:set` for options in filetype-specific plugins. Using `:setlocal` keeps modifications local to the current buffer, and it makes sense to keep filetype-specific modifications local to the buffer with the target filetype. See `:help :setlocal` and the `OPTIONS` section of `:help ftplugin` for reference.

- Use the `<buffer>` keyword with any key mappings (discussed in detail in **TODO** reference) used in filetype specific plugins---this keeps the mappings local to the buffer with the target file type. Analogously, consider using `<LocalLeader>` instead of `<Leader>` for leader key mappings in filetype-specific plugins---`<LocalLeader>` gives users the option to use filetype-specific leader keys.

  In fact, you can go down a whole rabbit hole of filetype-specific keymap safety mechanisms that I haven't listed here---see the `MAPPINGS` section of `:help ftplugin` if feeling inspired.

- Vim actually comes with built-in filetype plugins for common file types---you can view them at `$VIMRUNTIME/ftplugin`. To use most of a built-in filetype plugin and only overwrite a few settings, put your modifications in `nvim/after/ftplugin/filetype.vim`. Vim's built-in filetype plugin will be loaded, and then whatever you have in `after/` will overwrite any settings you changed. Reference: the `DISABLING` section of `:help ftplugin`.

### Autoload functions
See `:help autoload-functions`. Basically...
- In an `autoload/` directory somewhere in your Vim runtimepath, create a Vimscript file `my_functions.vim`. Inside `autoload/my_functions.vim`, define a function with the syntax
  ```
  function my_functions#function_name()
    " function body
  endfunction
  ```
  The general syntax is `{filename}#{function-name}`. The `filename` must exactly match the name of the Vimscript file within which the function is defined. When autoloading functions, it is conventional that `function-name` starts with lowercase characters.

  Call the function as `call my_functions#function_name()`. What happens: Vim recognizes the `{filename}#{function-name}` syntax, realizes the function is an autoload function, and searches all `autoload` directories in your Vim runtimepath for files name `filename`, then within these files searchs for functions named `function_name`. If a match is found, a function is loaded into memory and should be visible with `:function`.


<!-- **Variables** -->
<!-- - For declaring internal variables, see `:help internal-variables` -->
<!-- - `:help variable-scope` -->
<!-- The period is the Vimscript string concatenation operator; see `:help expr5` for the official documentation. -->


