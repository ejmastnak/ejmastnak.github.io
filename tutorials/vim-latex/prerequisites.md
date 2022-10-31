---
title: Prerequisites for Vim-LaTeX Workflows \| Vim and LaTeX Series Part 1

prev-filename: "intro"
prev-display-name: ""
next-filename: "ultisnips"
next-display-name: "2. Snippets »"

date: 2022-01-24 11:22:07 -0800
date_last_mod: 2022-10-10 19:36:32 +0200
---

{% include vim-latex-navbar.html %}

# 1. Suggested Prerequisites for Writing LaTeX in Vim

{% include date.html %}

This is part one in a [seven-part series]({% link tutorials/vim-latex/intro.md %}) explaining how to use the Vim or Neovim text editors to efficiently write LaTeX documents.
I wrote this series with beginners in mind, but some prerequisite knowledge is unavoidable.
Each prerequisites is listed below and includes a suggestion or mini-tutorial for getting up to speed.
You should be comfortable with the material below to get the most out of this series.

## Contents of this article
<!-- vim-markdown-toc GFM -->

* [Operating system](#operating-system)
* [LaTeX knowledge](#latex-knowledge)
* [Vim knowledge](#vim-knowledge)
* [Literacy in basic Vim/Neovim differences](#literacy-in-basic-vimneovim-differences)
* [Vim plugins](#vim-plugins)
* [Navigating the Vim help](#navigating-the-vim-help)
* [Python 3 installation](#python-3-installation)
* [Command line usage](#command-line-usage)
* [Installing system packages](#installing-system-packages)
* [Shell scripting abbreviations](#shell-scripting-abbreviations)
* [The abbreviations e.g. and i.e.](#the-abbreviations-eg-and-ie)

<!-- vim-markdown-toc -->

### Operating system
**Prerequisite:** you are working on macOS, Linux, or some other Unix variant.

<details>
  <summary>
  <strong>Suggestion</strong> (click arrow to expand)
  </summary>
  <p>If you use Windows, I suggest you follow along with the series as is;
  you will still find plenty of helpful techniques and ideas, and if XYZ doesn't work as expected, search the Internet for “how to use XYZ Vim/LaTeX/shell feature on Windows”.
  I do not have formal experience with Windows and cannot offer advice at the level of detail required for this series, but there should be plenty of Windows users on the Internet more knowledgeable than I am who have figured out a solution or workaround.</p>

  <p>If you use some exotic flavor of Unix, I assume you know enough of what you are doing to adapt this series’s Linux-based suggestions to your platform.</p>

</details>

### LaTeX knowledge
**Prerequisite:** you know what LaTeX is, have a working LaTeX distribution installed locally on your computer, and know how to use it, at least for creating basic documents.
Among other things, this means you should have the `pdflatex` and `latexmk` programs installed on your system and available from a command line.

<details>
  <summary>
  <strong>Suggestions</strong> (click arrow to expand)
  </summary>
  <ul>
    <li>
      <p>See the <a href="https://www.latex-project.org/get/">LaTeX project’s official installation instructions</a> for installing LaTeX on various operating systems.</p>
    </li>
    <li>
      <p>I recommend the <a href="https://www.learnlatex.org/en/">tutorial at learnlatex.org</a> as a starting point for learning LaTeX.
    Another decent option, despite the clickbait title, is <a href="https://www.overleaf.com/learn/latex/Learn_LaTeX_in_30_minutes">Overleaf’s <em>Learn LaTeX in 30 minutes</em></a>.
      Note that you can find hundreds of other LaTeX guides on the Web, but this can be just as overwhelming as it is helpful.
      Be wary of poorly written or non-comprehensive tutorials, of which there are unfortunately plenty.
      The <a href="https://www.latex-project.org/help/links/">LaTeX project’s list of helpful links</a> is a good place to find high-quality documentation and tutorials.</p>
    </li>
  </ul>
</details>

### Vim knowledge
**Prerequisite:** you know what Vim is, have a working local installation of Vim/Neovim (or gVim/MacVim) on your computer, and know how to use it, at least for basic text editing (for example at the level of `vimtutor`).
At the risk of belaboring the obvious, this means you must have either the `vim` or `nvim` programs (or their GUI variants) installed and available on a command line.

<details>
  <summary>
  <strong>Suggestions</strong> (click arrow to expand)
  </summary>
  <ul>
    <li>Installation: Vim should come installed on most of the Unix-based systems this series is written for.
      Unfortunately the <a href="https://github.com/vim/vim#installation">official instructions for installing Vim</a> aren’t particularly inviting to beginners;
      for installation I suggest <a href="https://formulae.brew.sh/formula/vim">using Homebrew</a> on macOS or consulting your distribution’s package manager on Linux.</li>
    <li>
      <p>And here are the <a href="https://github.com/neovim/neovim/wiki/Installing-Neovim">official instructions for installing Neovim</a> (which are much friendlier to beginners than Vim’s instructions).
      <em>If you are choosing between Vim and Neovim specifically for the purpose of this series, I encourage you to choose Neovim</em>: connecting Neovim to your PDF reader will be easier because of Neovim’s implementation of the remote procedure call protocol.</p>
    </li>
    <li>To get started with Vim/Neovim, try the interactive Vim tutorial (usually called the “Vim tutor”) that ships with Vim.
  You access the Vim tutor differently depending on your choice of Vim and Neovim.
      <ul>
        <li>If you have Vim (or gVim or MacVim) installed: open a terminal emulator and enter <code class="language-plaintext highlighter-rouge">vimtutor</code>.</li>
        <li>If you have Neovim installed: open Neovim by typing <code class="language-plaintext highlighter-rouge">nvim</code> in a terminal.
  Then, from inside Neovim, type <code class="language-plaintext highlighter-rouge">:Tutor</code> and press the Enter key to open the Vim tutor.</li>
      </ul>

      <p>After (or in place of) the Vim tutor, consider reading through <a href="https://github.com/iggredible/Learn-Vim">Learn Vim the Smart Way</a>.</p>
    </li>
  </ul>
</details>

### Literacy in basic Vim/Neovim differences
**Prerequisite:** if you use Neovim, you should know how to navigate the small differences between Neovim and Vim, for example Neovim's `init.vim` file replacing Vim's `vimrc` or the user's Neovim configuration files living at `~/.config/nvim` as opposed Vim's `~/.vim`.

(Nontrivial differences, such as the server configuration required to set up inverse search with a PDF reader, are explained separately for both editors.)

<details>
  <summary>
  <strong>Suggestion</strong> (click arrow to expand)
  </summary>
  <p>Read through Neovim’s <code class="language-plaintext highlighter-rouge">:help vim-differences</code> or <a href="https://neovim.io/doc/user/vim_diff.html">read the equivalent online version</a>.</p>
</details>

### Vim plugins
**Prerequisite:** you have installed Vim plugins before,
have a preferred plugin installation method (e.g. Vim 8+/Neovim's built-in plugin system, [`vim-plug`](https://github.com/junegunn/vim-plug), [`packer`](https://github.com/wbthomason/packer.nvim), etc...),
and will know what to do when told to install a Vim plugin.

<details>
  <summary>
  <strong>Suggestion</strong> (click arrow to expand)
  </summary>
  <ul>
    <li>
      <p>For most users, I suggest using the well-regarded <a href="https://github.com/junegunn/vim-plug">Vim-Plug plugin</a> to manage your plugins (yes, this is a plugin that manages other plugins).
      The <a href="https://github.com/junegunn/vim-plug">Vim-Plug GitHub page</a> contains everything you need to get started.</p>
    </li>
    <li>
      <p>If you prefer to manage your plugins manually, without third-party tools, use Vim/Neovim’s built-in plugin management system.
  The relevant documentation lives at <code class="language-plaintext highlighter-rouge">:help packages</code> but is unnecessarily complicated for a beginner’s purposes.
  When getting started with the built-in plugin system, it is enough to perform the following:</p>
      <ol>
        <li>Create the folder <code class="language-plaintext highlighter-rouge">pack</code> inside your root Vim configuration folder (i.e. create <code class="language-plaintext highlighter-rouge">~/.vim/pack/</code> if using Vim and <code class="language-plaintext highlighter-rouge">~/.config/nvim/pack/</code> if using Neovim).</li>
        <li>Inside <code class="language-plaintext highlighter-rouge">pack/</code>, create an arbitrary number of directories used to organize your plugins by category (e.g. create <code class="language-plaintext highlighter-rouge">pack/global/</code>, <code class="language-plaintext highlighter-rouge">pack/file-specific/</code>, etc.).
           These names can be anything you like and give you the freedom to organize your plugins as you see fit.
           You probably just want to start with one plugin directory, e.g. <code class="language-plaintext highlighter-rouge">pack/plugins/</code>, and create more if needed as you plugin collection grows.</li>
        <li>Inside each of the just-created organizational directories, create a directory named <code class="language-plaintext highlighter-rouge">start/</code> (you will end up with e.g. <code class="language-plaintext highlighter-rouge">pack/plugins/start/</code>).</li>
        <li>Clone a plugin repository from GitHub into a <code class="language-plaintext highlighter-rouge">start/</code> directory.</li>
      </ol>

      <p>Since that might sound abstract, an example shell session used to install the <a href="https://github.com/lervag/vimtex">VimTeX</a>, <a href="https://github.com/SirVer/ultisnips">UltiSnips</a>, and <a href="https://github.com/tpope/vim-dispatch">Vim-Dispatch</a> plugins (all used later in this series) using Vim/Neovim’s built-in plugin system would look like this:</p>
      <div class="language-sh highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="c"># Change directories to the root Vim config directory</span>
  <span class="nb">cd</span> ~/.vim         <span class="c"># for Vim</span>
  <span class="nb">cd</span> ~/.config/nvim  <span class="c"># for Neovim</span>

  <span class="c"># Create the required package directory structure</span>
  <span class="nb">mkdir</span> <span class="nt">-p</span> pack/plugins/start
  <span class="nb">cd </span>pack/plugins/start

  <span class="c"># Clone the plugins' GitHub repos from inside `start/`</span>
  git clone https://github.com/lervag/vimtex
  git clone https://github.com/SirVer/ultisnips
  git clone https://github.com/tpope/vim-dispatch
  </code></pre></div>    </div>
      <p>For orientation, the resulting file structure would be:</p>
      <div class="language-sh highlighter-rouge"><div class="highlight"><pre class="highlight"><code>~/.vim/
  └── pack/
      └── plugins/
          └── start/
              ├── vimtex/
              ├── ultisnips/
              └── vim-dispatch/
  </code></pre></div>    </div>
      <p>The VimTeX, UltiSnips, and Vim-Dispatch plugins would then automatically load whenever Vim starts up.</p>

      <p>If you install a plugin manually, its documentation will not be automatically available with Vim’s <code class="language-plaintext highlighter-rouge">:help</code> command.
  To generate the plugin documentation, first ensure the plugin has a <code class="language-plaintext highlighter-rouge">doc</code> directory, which is where documentation should be stored.
  If a plugin <code class="language-plaintext highlighter-rouge">doc</code> directory exists, you can generate its documentation with the Vim command</p>
      <div class="language-vim highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="p">:</span><span class="k">helptags</span> <span class="sr">/path/</span><span class="k">to</span><span class="sr">/plugin/</span>doc
  </code></pre></div>    </div>
      <p>You can also just use <code class="language-plaintext highlighter-rouge">:helptags ALL</code> to generate documentation for all plugins with a <code class="language-plaintext highlighter-rouge">doc</code> directory;
    see <code class="language-plaintext highlighter-rouge">:help helptags</code> for background.</p>
    </li>
  </ul>
</details>

### Navigating the Vim help
**Prerequisite:** You should be comfortable using Vim/Neovim's excellent built-in documentation, which you access with the `:help` command.

<details>
  <summary>
  <strong>Quick crash course</strong> (click arrow to expand)
  </summary>

  <p>The Vim documentation is hyperlinked, and if you have syntax highlighting enabled, clickable hyperlinks to help chapters and sections should be clearly highlighted.
  The following two key combinations are your friend:</p>

  <ul>
  <li>Press <code class="language-plaintext highlighter-rouge">&lt;Ctrl&gt;]</code> (i.e. the control key and the right square bracket) with your cursor over a highlighted documentation section to jump to that section</li>
  <li>Press <code class="language-plaintext highlighter-rouge">&lt;Ctrl&gt;o</code> (the control key and the lowercase <code class="language-plaintext highlighter-rouge">o</code>) to jump backward through your navigation history (e.g. to return to your original position before pressing <code class="language-plaintext highlighter-rouge">&lt;Ctrl&gt;]</code>)</li>
  </ul>

  <p>For more information, read <code class="language-plaintext highlighter-rouge">:help 01.1</code>, which explains the basics of the Vim documentation, and <code class="language-plaintext highlighter-rouge">:help notation</code>, which explains the notation used in the Vim documentation</p>

</details>

### Python 3 installation
**Prerequisite:** you have a working Python 3+ installation and are able to use `pip/pip3` to install Python packages.

<details>
  <summary>
  <strong>Suggestion</strong> (click arrow to expand)
  </summary>

  <p>I suggest installing Python using your distribution's package manager on Linux and using Homebrew on macOS.
  Both of these options should give you a reliable, up-to-date version of Python that includes <code class="language-plaintext highlighter-rouge">pip</code>.
  If you discover that you have multiple, conflicting installations of Python on your system (this is risk on macOS in particular, which ships an outdated version by default), refer to one of the many guides on the Internet for cleaning up a Python 3 installation on your operating system.</p>

  <p>In any case, you should end up with the <code class="language-plaintext highlighter-rouge">python</code>/<code class="language-plaintext highlighter-rouge">python3</code> and <code class="language-plaintext highlighter-rouge">pip</code>/<code class="language-plaintext highlighter-rouge">pip3</code> commands available from a command line.</p>
</details>

### Command line usage
**Prerequisite:** You are comfortable with the concept of calling simple command line programs from a terminal emulator, for example using `pdflatex myfile.tex` to compile the LaTeX file `myfile.tex`, using `python3 myscript.py` to run a Python script, or even something as simple as `echo "Hello world!"` to write text to standard output.

<details>
  <summary>
  <strong>Suggestion</strong> (click arrow to expand)
  </summary>
  <p>I tentatively assume that someone interested in using a command line editor like Vim is already familiar with the command line.
  But in case you need practice, search YouTube for one of the many guides on getting started with the command line.</p>
</details>

### Installing system packages
**Prerequisite:** you have a preferred method for installing new software onto your computer and know yow to use it.

<details>
  <summary>
  <strong>Suggestion</strong> (click arrow to expand)
  </summary>
  <p>Use your distribution’s package manager on Linux and the <a href="https://brew.sh/">Homebrew package manager</a> on macOS.</p>
</details>

### Shell scripting abbreviations
**Prerequisite:** You are familiar with the more common abbreviations and macros used in shell scripting.

<details>
  <summary>
  <strong>Quick crash course</strong> (click arrow to expand)
  </summary>
  <p>The abbreviations you should know for this series are:</p>
  <ul>
    <li><code class="language-plaintext highlighter-rouge">~</code> (the tilde) is shorthand for the home directory</li>
    <li><code class="language-plaintext highlighter-rouge">.</code> is shorthand for the current working directory</li>
    <li><code class="language-plaintext highlighter-rouge">..</code> is shorthand for one directory above the current working directory</li>
    <li><code class="language-plaintext highlighter-rouge">*</code> is the match-all wildcard character used in <a href="https://en.wikipedia.org/wiki/Glob_(programming)">glob patterns</a>.</li>
  </ul>
</details>

### The abbreviations e.g. and i.e.
**Prerequisite:** You know what "e.g." and "i.e." mean---I will use both throughout this series.
(While these abbreviations might be obvious to some people, they could very well be exotic to others, for example non-native English speakers or anyone previously unfamiliar with technical or academic writing.)

<details>
  <summary>
  <strong>Quick crash course</strong> (click arrow to expand)
  </summary>
  <ul>
    <li>
      <p>“e.g.” means “for example”; it is an abbreviation of the Latin phrase <em>exemplī grātiā</em>, which means “for the sake of an example”.
  For more information consult <a href="https://en.wiktionary.org/wiki/e.g.">Wiktionary</a> or the Internet.</p>

      <p>Example:</p>
      <blockquote>
        <p>The VimTeX function <code class="language-plaintext highlighter-rouge">vimtex#syntax#in_mathzone()</code> returns <code class="language-plaintext highlighter-rouge">1</code> if the cursor is inside a LaTeX math zone (<strong>e.g.</strong> inside an <code class="language-plaintext highlighter-rouge">equation</code> environment or between inline math <code class="language-plaintext highlighter-rouge">$ $</code> symbols) and <code class="language-plaintext highlighter-rouge">0</code> otherwise.</p>
      </blockquote>

      <p>Equivalent meaning, using “for example”:</p>
      <blockquote>
        <p>The VimTeX function <code class="language-plaintext highlighter-rouge">vimtex#syntax#in_mathzone()</code> returns <code class="language-plaintext highlighter-rouge">1</code> if the cursor is inside a LaTeX math zone (<strong>for example</strong> inside an <code class="language-plaintext highlighter-rouge">equation</code> environment or between inline math <code class="language-plaintext highlighter-rouge">$ $</code> symbols) and <code class="language-plaintext highlighter-rouge">0</code> otherwise.</p>
      </blockquote>
    </li>
    <li>
      <p>“i.e.” means “that is” and is usually used as a clarification of a previous statement; it is an abbreviation of the Latin phrase <em>id est</em>, which, surprise surprise, means “that is”.
  For more information consult <a href="https://en.wiktionary.org/wiki/i.e.">Wiktionary</a> or search the Internet.</p>

      <p>Example:</p>
      <blockquote>
        <p>The VimTeX shortcuts <code class="language-plaintext highlighter-rouge">[*</code> and <code class="language-plaintext highlighter-rouge">]*</code> let you move between the boundaries of LaTeX comments (<strong>i.e.</strong> any text beginning with <code class="language-plaintext highlighter-rouge">%</code>)</p>
      </blockquote>

      <p>Equivalent meaning, using “that is”:</p>
      <blockquote>
        <p>The VimTeX shortcuts <code class="language-plaintext highlighter-rouge">[*</code> and <code class="language-plaintext highlighter-rouge">]*</code> let you move between the boundaries of LaTeX comments (<strong>that is</strong> any text beginning with <code class="language-plaintext highlighter-rouge">%</code>)</p>
      </blockquote>
    </li>
  </ul>

  <p>Probably thanks to their conciseness, “e.g.” and “i.e.” commonly appear in technical and academic writing;
they look weird the first time you see them, but you quickly get used to and come to appreciate them.</p>
</details>

{% include vim-latex-navbar.html %}

{% include vim-latex-license.html %}
