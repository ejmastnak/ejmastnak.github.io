---
title: Vimscript Theory \| Setting Up Vim for LaTeX Part 1
---
# Vimscript Theory for Filetype-Specific Workflow

## About the series
This is part one in a four-part series explaining how to use the Vim text editor to efficiently write LaTeX documents. This article provides a theoretical background for Vimscript use in filetype-specific workflows and is more general than the other articles, since its contents apply just as well to filetypes other than LaTeX.

Visit [the introduction]({% link tutorials/vim-latex/intro.md %}) for an overview of the series. Use the list below navigate to other parts in the series...
1. [Vimscript best practices for filetype-specific plugins]({% link tutorials/vim-latex/vimscript.md %})
1. [Compiling LaTeX documents from within Vim]({% link tutorials/vim-latex/compilation.md %})
1. [Integrating Vim and a PDF reader]({% link tutorials/vim-latex/pdf-reader.md %})
1. [Snippets: the key to real-time LaTeX]({% link tutorials/vim-latex/ultisnips.md %})


## Contents of this article
<!-- vim-markdown-toc Marked -->

* [General considerations for file-specific Vim plugins](#general-considerations-for-file-specific-vim-plugins)
  * [What is a plugin?](#what-is-a-plugin?)
    * [Runtimepath](#runtimepath)
  * [Filetype plugins](#filetype-plugins)
  * [Context: Working with filetype plugins](#context:-working-with-filetype-plugins)
  * [Writing Vimscript functions in filetype plugins](#writing-vimscript-functions-in-filetype-plugins)

<!-- vim-markdown-toc -->

## General considerations for file-specific Vim plugins

### What is a plugin?
A *plugin* is the familiar name for a Vimscript file that is loaded when you start Vim. See `help plugin`. If you have every created a `vimrc` or `init.vim` file, you have technically written a Vim plugin. Just like your `vimrc`, the purpose of plugins is to extend Vim's default functionality.

A *package* is a set of Vimscript files---see `help packages`. To be pedantic, what most people think of as a Vim plugin is technically a package. That's irrelevant; the point is that plugins and packages are the same type of file as your `vimrc`, and if you have every written a `vimrc` it is within your means to write more advanced plugins, too.

#### Runtimepath
Your Vim runtimepath is a list of directories, both in your home directory and system-wide, that Vim searches for files to load at runtime, i.e. when opening Vim. 

Here is a list of some directories on Vim's default runtimepath, taken from `help runtimepath`---you have probably seen some of them before.

> | Directory or File | Description |
> | ----------------- | ----------- |
> | filetype.vim |	filetypes by file name |
> | autoload |	automatically loaded scripts | 
> | colors/ | color scheme files             | 
> | compiler/ | compiler files               | 
> | doc/ | documentation                    | 
> | ftplugin/ | filetype plugins             | 
> | indent/ | indent scripts                 | 
> | pack/ | packages                       | 
> | spell/ | spell checking files             | 
> | syntax/ | syntax files                   | 

If you want your own plugin to load when you open Vim, you need to place the plugin in an appropriate location in your runtimepath.

- `:echo &rtp`

### Filetype plugins

files in certain locations are automatically loaded into your runtimepath when you start Vim. See `help runtimepath`.

- Set `:filetype plugin on` and put `tex` specific mappings and functions in `~/.vim/ftplugin/tex.vim`  and not in `vimrc`. Then these mappings will be used only for `tex` files. Obvious now of course.
  
  See `h: add-filetype-plugin` and `h: write-filetype-plugin`
  
- Programmatically recognizing filetypes: done automatically for all standard filetypes. Use `:set filetype?` in opened file to check filetype was set successfully.

  Manual detection for weird filetypes, using the example of `subrip` filetype, which has an `.srt` extension. Create `~/.vim/ftdetect/subrip.vim`
  ```
  autocommand BufNewFile,BufRead *.srt set filetype=subrip
  ```

- `setlocal` instead of `set` is best practice for buffer-local modifications like in `ftplugin`.


### Context: Working with filetype plugins
The relevant documentation lives at `:help filetype` and `:help ftplugin`, but is rather long. For our purposes:

- Include `:filetype on` in your `init.vim` to enable filetype detection.

- When you open a file with Vim, Vim determines the file's `filetype` by checking the file's extension with a set of autocommands defined in  `$VIMRUNTIME/filetype.vim`. For nearly all files (including LaTeX files with the `.tex` or `.latex` extensions), Vim's filetype detection works out of the box.

- If Vim successfully detects the file's file type, it sets the value of the `filetype` option to indicate the file type. Generally, but not always, the value of `filetype` matches the file's conventional extension; for LaTeX this value is `filetype=tex`. You can check the current value of `filetype` with `:set filetype?`.

- After the `filetype` option is set, Vim checks the contents of your `nvim/ftplugin` directory, if you have one. The contents of `ftplugin` should be either files with the name `{filetype}.vim` or directories with the name `{filetype}`, where `{filetype}` is the same as the value of `set filetype?`; for LaTeX files you use `tex`. The contents of any matching files are then loaded into your runtime path.

Best practice: make a file-specific `{filetype}.vim` file inside `nvim/ftplugin` to hold your file-specific Vim settings. Think of `ftplugin/{filetype.vim}` as a `vimrc`/`init.vim` for that `filetype` only. Keep your `init.vim` for global settings you want to apply to all files.

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
