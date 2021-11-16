---
title: Vimscript Theory \| Setting Up Vim for LaTeX Part 1
---
# Vimscript Theory for Filetype-Specific Workflow

## About the series
This is part one in a [four-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents. This article provides a theoretical background for use of Vimscript in filetype-specific workflows.

## Contents of this article
<!-- vim-markdown-toc Marked -->

* [How to read this article](#how-to-read-this-article)
* [General considerations for file-specific Vim plugins](#general-considerations-for-file-specific-vim-plugins)
  * [What is a plugin?](#what-is-a-plugin?)
    * [Runtimepath: where Vim looks for files to load](#runtimepath:-where-vim-looks-for-files-to-load)
  * [Filetype plugins](#filetype-plugins)
    * [Filetype plugin "Hello World"](#filetype-plugin-"hello-world")
    * [Automatic filetype detection](#automatic-filetype-detection)
    * [Manual filetype detection](#manual-filetype-detection)
    * [How Vim loads filetype plugins](#how-vim-loads-filetype-plugins)
* [Writing Vimscript functions](#writing-vimscript-functions)
  * [How to read this section](#how-to-read-this-section)
  * [Function definition syntax](#function-definition-syntax)
  * [Best practices for writing functions](#best-practices-for-writing-functions)
* [Filetype plugins](#filetype-plugins)
  * [Plugin best practices](#plugin-best-practices)
  * [Script-local functions](#script-local-functions)
    * [Why script-local functions](#why-script-local-functions)
    * [Calling script-local functions with key mappings](#calling-script-local-functions-with-key-mappings)
  * [Autoload functions](#autoload-functions)
  * [Mappings](#mappings)

<!-- vim-markdown-toc -->

## How to read this article
This article is long. You don't have to read everything---I suggest skimming through on a first reading, remembering this article exists, and then referring back to it, if desired, for a theoretical understanding of the Vimscript functions and key maps used later in the series.


By the way, nothing in this particular article is LaTeX-specific, and generalizes perfectly to filetype-specific workflows completely unrelated to LaTeX.

## General considerations for file-specific Vim plugins

### What is a plugin?
A *plugin*, as defined in `:help plugin`, is the familiar name for a Vimscript file (generally a `.vim` file) that is loaded when you start Vim. If you have every created a `vimrc` or `init.vim` file, you have technically written a Vim plugin. Just like your `vimrc`, a plugin's purpose is to extend Vim's default functionality to meet your personal needs.

A *package*, as defined in `:help packages`, is a set of Vimscript files. To be pedantic, what most people (myself included) refer to in everyday usage as a Vim plugin is technically a package. That's irrelevant; the point is that plugins and packages are just Vimscript files used to extend Vim's default functionality, and if you have ever written a `vimrc` or `init.vim` it is within your means to write more advanced plugins, too.

#### Runtimepath: where Vim looks for files to load
If you have ever wondered which files are fair game for Vim to load at startup, the answer is the files in your *runtimepath*. Your Vim runtimepath is a list of directories, both in your home directory and system-wide, that Vim searches for files to load at runtime, i.e. when opening Vim. Below is a list of some directories on Vim's default runtimepath, taken from `:help runtimepath`---you will probably recognize some of them from your own computer.

> | Directory or File | Description |
> | ----------------- | ----------- |
> | filetype.vim |	filetypes by file name |
> | autoload |	automatically loaded scripts | 
> | colors/ | color scheme files             | 
> | compiler/ | compiler files               | 
> | doc/ | documentation                     | 
> | ftplugin/ | filetype plugins             | 
> | indent/ | indent scripts                 | 
> | pack/ | packages                         | 
> | spell/ | spell checking files            | 
> | syntax/ | syntax files                   | 

You can view your current runtimepath with `:echo &runtimepath`.
If you want a plugin to load automatically when you open Vim, you must place the plugin in an appropriate location in your runtimepath. The filetype plugins covered in this tutorial should be placed in your `~/.vim` folder's `ftplugin/` directory. (For orientation, for example, customizations to your indentation settings should go in `~/.vim/indent/` and customizations to your colorscheme in `~/.vim/colors/`. This is beyond the scope of this article; see `:help runtimepath` for more.)

### Filetype plugins
Use case for filetype plugins: you've written some customizations that you want to apply only to LaTeX files (say), and not to any other file types. To keep your LaTeX customizations local to only LaTeX files, you should use Vim's filetype plugin system.

#### Filetype plugin "Hello World"
Here's what to do:
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
- Vim keeps track of a file's filetype using the `filetype` variable. You can view a file's Vim filetype with the commands `:echo &filetype` or `:set filetype?`.

- Once you set `:filetype on`, Vim automatically detects common filetypes (LaTeX included) based on the file's extension using a Vimscript file called `filetype.vim` that ships with Vim. You can view the source code at the path `$VIMRUNTIME/filetype.vim` (use `:echo $VIMRUNTIME` in Vim to determine `$VIMRUNTIME`).


#### Manual filetype detection
Manual detection of exotic filetypes is not needed for this tutorial. Feel free to skip ahead. But if you're curious, here's an example using LilyPond files, which by convention have the extension `.ly`. (LilyPond is a FOSS text-based system for elegantly typesetting musical notation; as an analogy, LilyPond is for music what LaTeX is for math.)

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
*Everything in this article comes from the help document `eval.txt`*, which covers everything a typical user would need to know about Vimscript expressions. You can access it with `:help eval.txt`. Since `eval.txt` is over 12000 lines and not terribly inviting to beginners, I am using this section to provide, in condensed form, the information I have subjectively found most relevant for a typical user getting started with writing Vimscript functions.

But please keep in mind: this article is *not* an attempt to replace `eval.txt`, nor is it a rigorous Vimscript tutorial. It is a summary of the basic Vimscript rules presented in a way that should hopefully be easier for a new user to grasp than tackling `eval.txt` directly, together with references of exactly where in the Vim docs to find more information. My goal is to make it easier for you to get started and avoid some common pitfalls; you can then return to eval.txt once you find your footing.

Note: the help document `usr_41.txt` contains a summary of Vimscript. There is some overlap between `usr_41.txt` and `eval.txt`. In my experience the coverage of functions in `eval.txt` is more comprehensive but less easy to read, like a `man` page, while the coverage of functions in  `usr_41.txt` is an incomplete summary of the material from `eval.txt`.

### Function definition syntax
Terminology: *Vim functions* are functions built-in to Vim, while *user functions* are custom functions written by a user.

- From `:help E124`, the name of a user-defined function...

  > ... must be made of alphanumeric characters and `_`, and must start with either a capital letter or `s:`

  Also from the Vim docs at `:help user-function`:

  > [a user] function name must start with an uppercase letter, to avoid confusion with built-in functions. A good habit is to start the function name with the name of the script, e.g., `HTMLcolor()`.

  The Vim documentation makes the capital letter requirement sound more severe than it is. Your functions will work fine if they start with a lower-case letter as long as they don't conflict with existing Vim functions. (For example, Tim Pope's excellent [`vim-commentary`](https://github.com/tpope/vim-commentary) and [`vim-surround`](https://github.com/tpope/vim-surround) plugins use lowercase function names.) And a special class of functions called *autoload functions* often start with lowercase letters. But by using uppercase function names, you *ensure* your functions won't conflict with built-in functions.

-  Adding `!` after a `function` declaration, as in `function! {function-name}`, will overwrite any pre-existing functions called `{function-name}`. See `:help E127` for reference.

- The words `range`, `abort`, `dict`, and `closure` may all optionally be added to a function name. They go after the function's arguments, e.g. 
  ```vim
  function MyFunction() abort
    " function body
  endfunction
  ```
  Read about them at `:help :func-range`, `:help :func-abort`, `:help :func-dict`, `:help :func-closure`, respectively. I only use `abort` in this series; appending `abort` to a function definition stops function execution immediately if an error occurs during function execution.

- Function arguments are placed between parentheses, separated by commas, and are accessed from within the function by prepending `a:` (for "argument"). To give you a feel for the syntax:
  ```vim
  function MyFunction()
    echo "I don't have any arguments!"
  endfunction

  function MyFunction(arg1, arg2)
    echo "I have two arguments!"
    echo "Argument 1: " . a:arg1
    echo "Argument 2: " . a:arg2
  endfunction
  ```
  See `:help function-argument` for documentation of how function arguments work and how to use them.

- Use `:function` to list all loaded user functions (expect a long list if you use plugins). See `:help :function` (and not `:help function`, which lacks a colon before "function") for more on listing functions and finding where they were defined.

### Best practices for writing functions
These suggestions come from section 10 in `usr_41.txt`; you can access the original with `:help 41.10`. The chapter `41.10` gives a collection of best practices for writing Vim scripts; for functions in particular, scroll down to the `PACKAGING` section of `:help 41.10`. Summarizing...

- Prepend a unique, memorable string before all related functions in a Vimscript file, for example an abbreviation of the script name. For LaTeX-related functions in a script `tex.vim`, for example, one might write
  ```vim
  function TexCompile
    " function body
  endfunction

  function TexForwardShow
    " function body
  endfunction

  " and so on...
  ```
  Prepending this short, memorable string to related functions keeps your Vimscript more organized.

- Keep related user-defined functions in a single file, and use a global variable to track if the functions have already been loaded. Copying from the docs...
  ```
  " This file might implement LaTeX-PDF integration, for example

  if exists("g:tex_functions_loaded")
    delfun TexCompile      " unloaded one function
    delfun TexForwardShow  " unloaded second function
    " and so on...
  endif
  let g:tex_functions_loaded = 1

  function TexCompile(a)
    " function body
  endfunction

  function TexForwardShow(b)
    " function body
  endfunction

  " and so on...
  ```

## Filetype plugins

### Plugin best practices
For plugin-specific best practices, see `:help write-plugin` and `:help write-filetype-plugin`. Here are some best practices:

- Use a global variable, e.g. something along the lines of `g:loaded_myplugin`, as a safety mechanism to prevent loading the plugin twice. Then include this Vimscript at the start of the plugin:
  ```
  if exists("g:loaded_myplugin")  " if `g:loaded_myplugin` exists, the plugin has already been loaded
    finish  " exit immediately
  endif
  let g:loaded_myplugin = 1       " record that plugin has been loaded
  ```
  This techinique also allows users to disable loading the plugin, if desired---a user who wouldn't want to use the plugin would set `g:loaded_myplugin = 1` (or any other value, as long as they create the variable) somewhere in their `vimrc`. Reference: the `NOT LOADING` section of `:help write-plugin`.

- Use `:setlocal` instead of `:set` for options in filetype-specific plugins. Using `:setlocal` keeps modifications local to the current buffer, and it makes sense to keep filetype-specific modifications local to the buffer with the target filetype. References: `:help :setlocal` and the `OPTIONS` section of `:help ftplugin`.

- Use the `<buffer>` keyword with any key mappings (discussed in detail in **TODO** reference) used in filetype specific plugins---this keeps the mappings local to the buffer with the target file type. Analogously, consider using `<LocalLeader>` instead of `<Leader>` for leader key mappings in filetype-specific plugins. The net effect gives users the option to use filetype-specific leader keys.

  In fact, you can go down a whole rabbit hole of filetype-specific keymap safety mechanisms that I haven't listed here---see the `MAPPINGS` section of `:help ftplugin` if inspired.

- Vim comes with built-in filetype plugins for common file types---you can view them at `$VIMRUNTIME/ftplugin`. To use most of a built-in filetype plugin and only overwrite a few settings, put your modifications in `nvim/after/ftplugin/filetype.vim`. Vim's built-in filetype plugin will be loaded, and then whatever you have in `after/` will overwrite any settings you changed. Reference: the `DISABLING` section of `:help ftplugin`.

### Script-local functions
Vim functions hae two possible scopes: global and script-local. Reference: `:help local-function`. I will cover script-local functions, which the Vim documentation recommends for use in filetype plugins.

To implement the functions and key maps used later in this series, we basically need to know:
- how to write a script local function
- how to define a mapping that makes the function accessible outside the script it was defined in.

Reference: `:help local-function` in `eval.txt` and `:help script-local` in `map.txt` for how to define useful mappings involving script-local functions.

From `:help local-function`, a script-local function can be called:

| Technique of calling I guess? | Scope |
| ----------------------------- | ----- |
| From Vimscript and from within Vimscript functions | only in the parent script |
| Via an autocommand defined in the parent script | anywhere |
| Via a user command defined in the parent script | anywhere |
| Via a key mapping | anywhere\* |

\* assuming you use the `<SID>` (script ID) mapping syntax.

#### Why script-local functions
As a best practice, use script-local functions in filetype-plugins. This avoids potential conflict with fuctions in other scripts. Example: if two scripts both defined `function s:SomeFunctionName`, no problems would occur because the functions are script-local, but if both scripts used `function SomeFunctionName`, the names would conflict, because the functions are global.

Note: using script-local functions is not a hard and fast rule. If you don't want to go through the bother of script-local functions and are certain your function names won't conflict with other scripts or plugins---especially if you don't intend to distribute your plugin to others---you don't need to make every function script-local. In fact, plenty of well-known filetype plugins from reputable authors include global functions, such as `MarkdownFold` and `MarkdownFoldText` in Tim Pope's [`vim-markdown`](https://github.com/tpope/vim-markdown), and everything works just fine.

#### Calling script-local functions with key mappings
The point here is to make script-local functions usable outside of the script in which they were written.

Reference: `:help map-<script>`

- Safely defining key mappings that call script-local functions requires a three-step process:
  1. Map the desired key combination to a `<Plug>` map
  2. Map `<Plug>` to a `<SID>` map
  3. Use the `<SID>` map to call the function.

  Kind of a bother, right? Oh well, consider it a peculiarity of Vim. And, if followed, this technique ensure functions from different scripts won't conflict, which is important for an editor with a rich plugin tradition.

- Here is a hello-world style recipe to follow, adapted from the official documentation in the `PIECES` section of `:help write-plugin`. If you want to use map the key sequence `<leader>c` to call the function `TexCompile` (defined as a script-local function at, say, `ftplugin/tex.vim`) in normal mode, proceed as follows:
  ```vim
  " in the file ftplugin/tex.vim (for example), define...

  function! s:TexCompile()
    " implement compilation functionality here
  endfunction

  " define key map here
  nmap <unique> <leader>c <Plug>TexCompileMapping  " 
  nnoremap <unique> <script> <Plug>TexCompileMapping <SID>TexCompile
  nnoremap <SID>TexCompile :call <SID>TexCompile()<CR>
  ```
  You could then use `<leader>c` in normal mode to call the `s:TexCompile` function from *any* file with the `tex` filetype.


- Explanation: `<leader>c` maps to `<Plug>TexCompile`, which maps to `<SID>Compile`, which maps to `:call <SID>TexCompile`. Note: it's important that `nmap <leader>c <Plug>TexCompile` is *not* a `nnoremap`, since it is *intended* that `<Plug>TexCompile` expand directly to `:call blahblah` or to `<SID>TexCompile`. Using `nnoremap` would be the equivalent of mapping `<leader>c` to literally typing the key sequence `<Plug>TexCompile` in normal mode.

  **TODO** explain how using `<script>` overrides `nnoremap` when mapping `<Plug>TexCompile` to `<SID>TexCompile`

-  Note that `<SID>`, `<Plug>`, and function names could all be different! It's just convention to name them the same I guess. **TODO** confirm changing names of `<Plug>` and `<SID>` and seeing what works.


- See `:help using-<Plug>` in `usr_41.txt` and probably also more thorough reference somewhere in `map.txt`

- If you want to be REALLY conservative,
  ```
	if !exists("g:no_plugin_maps") && !exists("g:no_tex_plugin_maps")
	  if !hasmapto('<Plug>TexCompile')
	    nmap <buffer> <LocalLeader>c <Plug>TexCompile
	  endif
    nnoremap <buffer> <script> <Plug>TexCompile <SID>TexCompile
    nnoremap <SID>Compile  :call <SID>TexCompile()<CR>
	endif
  ```
  The variable `g:no_plugin_maps` disables mappings for all filetype plugins while `g:no_tex_plugin_maps` disables mappings specific to the `tex` filetype plugin. Or use `g:no_my_tex_plugin_maps` or whatever.
  
- When defining functions use one of
  ```
  if !exists("s:MyFunction")
	  function s:MyFunction()
	    " function body
	  endfunction
  endif

  function! s:MyFunction()
    " function body
  endfunction
  ```
  From the `FUNCTION` section of `:help write-filetype-plugin`, the `filetype` plugin is sourced every time a file of the target file type is opened. The above constructs are two ways to make sure a function is not loaded twice. The second just overwrites existing functions.

  The first would in principle be faster since it is is just an if statement instead of overwriting and reloading a function from scratch like the second option. But the first is kind of a pain to write.

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
  
  

**Variables**
- For declaring internal variables, see `:help internal-variables`
- `:help variable-scope`

The period is the Vimscript string concatenation operator; see `:help expr5` for the official documentation.

