- Prerequisites crash course in appendix: installing Vim plugins, review of glob patterns.

- GIFs for snippets

- Vimtex plugin article:
  Read through manual and compile features
  Include compilation and PDF reader in this article

- Set up Zathura on Linux:

  Add a variable to Vim to keep track of if Zathura is opened.
  Basically if variable is empty launch Zathura from Vim and get the process ID.
  Once PID is registered only forward search Zathura without passing the inverse search command every time.

  You could use AyncRun for the end job code to unlet the PID variable on closing Zathura. but no you couldn't because then mpv wouldn't work.

  And then figure out how to call a script for inverse search.


