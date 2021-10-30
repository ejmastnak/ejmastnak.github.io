---
title: Vimscript Theory \| Setting Up Vim for LaTeX Part 1
---
# Vimscript Theory for Filetype-Specific Workflow

## About the series
This is part one in a [four-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim text editor to efficiently write LaTeX documents, and provides a theoretical background for use of Vimscript in filetype-specific workflows. This article is more general than rest, and its contents apply just as well to filetypes other than LaTeX.

## Contents of this article
<!-- vim-markdown-toc Marked -->

* [General considerations for file-specific Vim plugins](#general-considerations-for-file-specific-vim-plugins)
  * [What is a plugin?](#what-is-a-plugin?)
    * [Runtimepath: where Vim looks for files to load](#runtimepath:-where-vim-looks-for-files-to-load)
  * [Filetype plugins](#filetype-plugins)
  * [How Vim loads filetype plugins](#how-vim-loads-filetype-plugins)
  * [Writing Vimscript functions in filetype plugins](#writing-vimscript-functions-in-filetype-plugins)
* [TODO: My notes](#todo:-my-notes)
  * [Best practices](#best-practices)
  * [Plugin best practices](#plugin-best-practices)
  * [Script-local functions](#script-local-functions)
  * [Autoload functions](#autoload-functions)
  * [Mappings](#mappings)

<!-- vim-markdown-toc -->

## General considerations for file-specific Vim plugins

### What is a plugin?
A *plugin*, as defined in `help plugin`, is the familiar name for a Vimscript file that is loaded when you start Vim. If you have every created a `vimrc` or `init.vim` file, you have technically written a Vim plugin. Just like your `vimrc`, a plugins serves to extend Vim's default functionality.

A *package*, as defined in `help packages`, is a set of Vimscript files. To be pedantic, what most people (myself included) call a Vim plugin is technically a package. That's irrelevant; the point is that plugins and packages are just Vimscript files used to extend Vim's default functionality, and if you have ever written a `vimrc` it is within your means to write more advanced plugins, too.

#### Runtimepath: where Vim looks for files to load
Your Vim runtimepath is a list of directories, both in your home directory and system-wide, that Vim searches for files to load at runtime, i.e. when opening Vim. If you ever wondered which files are fair game for Vim to load, the answer is files in your runtimepath.

Here is a list of some directories on Vim's default runtimepath, taken from `help runtimepath`---you will probably recognize some of them from your own computer.

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

You can view your current runtimepath with `:echo &rtp`.
If you want your own plugin to automatically load when you open Vim, you need to place the plugin in an appropriate location in your runtimepath. This tutorial covers filetype plugins, which should be placed in your `~/.vim` folder's `ftplugin/` directory.


### Filetype plugins
Say you want to write a LaTeX-specific plugin that loads only when you edit `.tex` files. Here's what to do:

- Add the following lines to your `vimrc`
  ```
  filetype on             " enable filetype detection
  filetype plugin on      " load file-specific plugins
  filetype indent on      " load file-specific indentation
  ```
  These lines enable filetype detection and filetype-specific plugins and indentation; see `help filetype` for more information. You can get an overview of your current filetype status with the `:filetype` command; you are looking for something like
  ```
  filetype detection:ON  plugin:ON  indent:ON
  ```

- Create the file structure `~/.vim/ftplugin/tex.vim`. Your `tex` specific mappings and functions will go in `~/.vim/ftplugin/tex.vim`. That's it! Anything in `tex.vim` will be loaded only when editing files with the `tex` filetype, and will not interfere with your `vimrc` or other filetype plugins.

  If you prefer to divide your `tex` customizations among multiple files (instead of having a single, cluttered `tex.vim` file), you can create the file structure `~/.vim/ftplugin/tex/*.vim`. Any files in `~/.vim/ftplugin/tex/` will load automatically when editing files with the `tex` filetype.
  
  See `h: add-filetype-plugin` and `h: write-filetype-plugin`

**Automatic filetype detection**
- Vim keeps track of a file's filetype using the `filetype` variable. You can a file's filetype, accoding to Vim, with the commands `:echo &filetype` or `:set filetype`.

- Once you set `:filetype on`, Vim automatically detects common filetypes (LaTeX included) based on the file's extension using a Vimscript file called `filetype.vim` that ships with Vim. You can view the source code at the path `$VIMRUNTIME/filetype.vim` (use `:echo $VIMRUNTIME` in Vim to determine `$VIMRUNTIME`).


**Manual filetype detection**
- Manual detection of exotic filetypes is not needed for this tutorial. Feel free to skip ahead. But if you're curious, here's an example using LilyPond files, which have the extension `.ly`. (LilyPond is a FOSS text-based system for typesetting musical notation; LilyPond is for music what LaTeX is for math.)

- Record the extension(s) for the target filetype, e.g. `.ly` for LilyPond. 

- Decide on the value Vim's `filetype` should take for the target filetype. This can match the extension, but doesn't have to; I will use `lilypond`.

- Create a file at the location `~/.vim/ftdetect/lilypond.vim` (the file name can technically be anything, but by convention should match the desired value of `filetype`). Inside the file add the single line
  ```
  autocommand BufNewFile,BufRead *.ly set filetype=lilypond
  ```
  Of course replace `.ly` with your target extension and `lilypond` with your target filetype.


### How Vim loads filetype plugins
The relevant documentation lives at `help filetype` and `help ftplugin`, but is rather long. For our purposes:

- When you open a file with Vim, assuming you have set `:filetype on`, Vim tries to determine the file's type by cross-checking the file's extension againt a set of extensions found in `$VIMRUNTIME/filetype.vim`. For most all common files, this method works out of the box. If the file's type is not detected from extension, Vim attempts to guess the file type based on file contents using `$VIMRUNTIME/scripts.vim` (reference: `help filetype`). If both `$VIMRUNTIME/filetype.vim` and `$VIMRUNTIME/scripts.vim` fail, Vim checks the contents of `ftdetect` directories in your runtimepath, as described in above **TODO** manual filetype detection.

- If Vim successfully detects a file's type, it sets the value of the `filetype` option to indicate the file type. Often, but not always, the value of `filetype` matches the file's conventional extension; for LaTeX this value is `filetype=tex`. You can check the current value of `filetype` with `echo &filetype` or `:set filetype?`.

- After the `filetype` option is set, Vim checks the contents of your `~/.vim/ftplugin` directory, if you have one. If Vim finds...

  - a file `ftplugin/{filetype}.vim` (e.g. `filetype/tex.vim` for `filetype=tex`), then Vim loads the contents of `{filetype}.vim`

  - a directory `ftplugin/{filetype}` (e.g. `ftplugin/tex` for the `filetype=tex`), then Vim loads all files inside the `{filetype}` directory

Best practice: make a file-specific `{filetype}.vim` file inside `ftplugin/` to hold filetype-specific settings. Think of `ftplugin/{filetype.vim}` as a `vimrc` for that file type only. Keep your `init.vim` for global settings you want to apply to all files.

### Writing Vimscript functions in filetype plugins
The relevant documentation lives at `:help eval.txt`, in particular see `:help E124` for the rules of writing a function.
```
function! filename#function_name() abort
  " any Vimscript you want the function to execute
endfunction

noremap <Plug>TexCompile :call tex_compile#compile()<cr>
nmap <leader>c <Plug>TexCompile
```
If wanted to write a function called `compile` inside the file `tex_compile.vim`, the full function name would be `tex_compile#compile`. So: prefixing `filename#` to the function name is convention. It is useful for... TODO

Using `!` after `function` affects what happens if a function named `filename#function_name` already exists. Using `function!` overwrites the previously-existing function, while using `function` does not load the new function and displays an errors message. This is covered in `:help E127`. The idea is that using `!` *together* with the prefix `filename#` is safe.

Appending `abort` to the function definition stops function execution if an error occurs during function execution (see `:help func-abort`).

## TODO: My notes
- For declaring internal variables, see `help internal-variables`
- `help variable-scope`
- See `help vim-function` for documentation of all built-in functions provided by Vim. This is a large section.
- See `help user-function` for writing your own functions. From `help user-function`:
  > The function name must start with an uppercase letter, to avoid confusion with builtin functions.  To prevent from using the same name in different scripts avoid obvious, short names.  A good habit is to start the function name with the name of the script, e.g., `HTMLcolor()`.

  Example from `commentary.vim`
  ```
  function! s:go() abort
    " function body
  endfunction

  nnoremap <expr> <Plug>Commentary <SID>go()
  nmap gc <Plug>Commentary
  ```
  Example from `surround.vim`
  ```
  function! s:changesurround(...) 
    " function body
  endfunction

  nnoremap <silent> <Plug>Csurround  :<C-U>call <SID>changesurround()<CR>
  nmap cs  <Plug>Csurround
  ```
- Use `:function` to list all loaded functions. More on listing functions and finding where they were defined in `help :function`.

- From `help E124`, the name of a user-defined function...

  > ... must be made of alphanumeric characters and `_`, and must start with either a capital letter or `s:`
  
  Adding `!` after a function name will overwrite any existing function with the same name.

  The words `range`, `abort`, `dict`, and `closure` may all optionally be added to a function name. They go after the arguments, e.g. 
  ```
  function MyFunction() abort
    " function body
  endfunction
  ```
  Read about them at `help :func-range`, `help :func-abort`, `help :func-dict`, `help :func-closure`, respectively.

  I only use abort in this tutorial:

  > When the `abort` argument is added, the function will abort as soon as an error is detected.
  

- See `help function-argument` for how function arguments work. Function arguments are accessed from within the function by prepending `a:`
  ```
  function MyFunction(arg1) abort
    echo a:arg1
  endfunction
  ```

### Best practices
Read `help 41.10`, which is a collection of best practices for writing Vim scripts. In particular for managing functions, scroll down to the `PACKAGING` section of `help 41.10`. Summarizing...
- Prepend a unique, memorable string before each function name, for example an abbreviation of the script name in which the function is defined
  ```
  function TEX_Compile
    " function body
  endfunction
  ```
- Keep related user-defined functions in a single file, and use a global variable to track if the functions have already been loaded. Copying from the docs...
  ```
  " This is the TEX package

	if exists("g:TEX_functions_loaded")
	  delfun TEX_one  " unloaded first function
	  delfun TEX_two  " unloaded second function
	endif
	let g:TEX_loaded = 1

	function TEX_one(a)
    " function body
	endfunction

	function XXX_two(b)
    " function body
	endfunction
  " and so on...
  ```

### Plugin best practices
For plugin-specific best practices, see `help write-plugin` and `help write-filetype-plugin`

- Add a safety mechanism to prevent loading the plugin twice, and to allow users to not load the plugin
  ```
  if exists("g:loaded_myplugin")
    finish
  endif
  let g:loaded_myplugin = 1
  ```
  A user who wouldn't want to use the plugin would set `g:loaded_myplugin = 1` (or any other value, as long as the variable exists) in their `vimrc`. The variable should be global; the syntax with `loaded_{plugin-name}` is convention.

  Reference: the `NOT LOADING` section of `help write-plugin`

- Use `:setlocal` instead of `:set` for options in filetype-specific plugins. See the `OPTIONS` section of `help ftplugin`

  If you are really picky, use `<LocalLeader>` instead of `<Leader>` for leader key mappings in filetype-specific plugins. See the `MAPPINGS` section of `help ftplugin`


  - To use most of a built-in filetype plugin and only overwrite a few settings, put your modifications in `nvim/after/ftplugin/filetype.vim`. Default plugin will be loaded, and then whatever you have in `after/` will overwrite what it needs to eh.
  

### Script-local functions
- See `help local-function` in `eval.txt`.
  
  See `help script-local` in `map.txt` for how to define useful mappings involving script-local functions.

- Can be called from within the script it was defined in, and from functions, user commands, autocommands, and mappings defined in the script. Calling local functions from mappings requires the special `<SID>` syntax.

- As best practice, define all script-local functions with `s:FunctionName` (with a prepending `s:`) to avoid potential conflict with fuctions in other scripts. If two scripts defined functions called `FunctionName`, the names would conflict. If two scripts defined functions called `s:FunctionName`, you would be fine.

- Basically (adapting from documentation in the `PIECES` section of `help write-plugin`)
  ```
  nmap <unique> <leader>c <Plug>TexCompile
  nnoremap <unique> <script> <Plug>TexCompile <SID>TexCompile
 	nnoremap <SID>Compile  :call <SID>TexCompile()<CR>
  ```
  The sequence then goes like `<leader>c` > `<Plug>TexCompile` > `<SID>Compile` > `:call <SID>TexCompile`

  Note tha `<SID>`, `<Plug>`, and function names could all be different! It's just convention to name them the same I guess.

  **TODO** see `help map-<script>`

  **TODO** ha! It is *important* that `nmap <leader>c <Plug>TexCompile` is *not* a `nnoremap`, since it is *intended* that `<Plug>TexCompile` expand directly to `:call blahblah` or to `<SID>TexCompile`. Using `nnoremap` would be the equivalent of mapping `<leader>c` to literally typing the key sequence `<Plug>TexCompile` in normal mode.

   **TODO** explain how using `<script>` overrides `nnoremap` when mapping `<Plug>TexCompile` to `<SID>TexCompile`

- See `help using-<Plug>` in `usr_41.txt` and probably also more thorough reference somewhere in `map.txt`

- Just say somewhere: yeah, properly (safely) defining mappings to script-local functions requires a three-step process: first map the desired key combination to a `<Plug>` map, then map `<Plug>` to a `<SID>` map, then use the `<SID>` map to call the function.

- And then to be REALLY picky,
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
  From the `FUNCTION` section of `help write-filetype-plugin`, the `filetype` plugin is sourced every time a file of the target file type is opened. The above constructs are two ways to make sure a function is not loaded twice. The second just overwrites existing functions.

  The first would in principle be faster since it is is just an if statement instead of overwriting and reloading a function from scratch like the second option. But the first is kind of a pain to write.

### Autoload functions
See `help autoload-functions`. Basically...
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
  
  

