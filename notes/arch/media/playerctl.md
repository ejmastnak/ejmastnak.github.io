---
title: Media player control on Arch Linux
---

# Media player control

**Goal:** Trigger common media player actions (e.g. play, pause, skip forward, etc.) using convenient keyboard shortcuts.
Best served with this series's [volume control guide]({% link notes/arch/media/volume.md %}).

**References:**
- [ArchWiki: MPRIS](https://wiki.archlinux.org/title/MPRIS)
- [The freedesktop.org MPRIS specification](https://specifications.freedesktop.org/mpris-spec/latest/)
- [ArchWiki: Xbindkeys](https://wiki.archlinux.org/title/Xbindkeys)

### What's involved

There are three main players in the game here:

- The *media player remote interfacing specification* (MPRIS), a system-wide API for controlling media players managed by the [freedesktop.org](https://en.wikipedia.org/wiki/Freedesktop.org).

- `playerctl`, a utility for sending commands to any program implementing the MPRIS specification.
  Supported MPRIS client programs include:
  - The Firefox and Chromium web browsers
  - VLC
  - mpv (via the [`mpv-mpris` plugin](https://github.com/hoyon/mpv-mpris))

  See [ArchWiki: MPRIS/Supported clients](https://wiki.archlinux.org/title/MPRIS#Supported_clients) for a longer list of media players that support MPRIS. 

- `xbindkeys`, a utility for defining key bindings in X.

## Procedure

There are two independent tasks in this article: (1) learning the commands to control `playerctl` and (2) binding these commands to keyboard keys using `xbindkeys`.

<!-- vim-markdown-toc GFM -->

* [Using `playerctl`](#using-playerctl)
  * [Hello world](#hello-world)
  * [Multiple media players](#multiple-media-players)
  * [Using `playerctl` with `mpv`](#using-playerctl-with-mpv)
* [Key bindings for media controls](#key-bindings-for-media-controls)
  * [Detect key symbols](#detect-key-symbols)
  * [Define key bindings in `.xbindkeysrc`](#define-key-bindings-in-xbindkeysrc)
  * [Activate key bindings](#activate-key-bindings)

<!-- vim-markdown-toc -->

### Using `playerctl`

#### Hello world

First install the [`playerctl` package](https://archlinux.org/packages/?name=playerctl):

```
sudo pacman -S playerctl
```
The `playerctl` utility offers intuitively-named commands; we'll use two:

- `playerctl play-pause` (toggle play/pause for the current media player)
- `playerctl next|previous` (skip to the next or previous track)

See `man playerctl` for a clearly-described list of other commands.

Manual usage of `playerctl` is straightforward.
For example:
1. First play some audio or video in an MPRIS client (e.g. play a YouTube video in Firefox, an MP3 file with VLC, etc.).
1. With the media playing, run e.g. `playerctl play-pause` from a command line.
   The media player should pause.
1. Run `playerctl play-pause` again.
   The media player should being playing again.

Running other `playerctl` commands is analogous, e.g. `playerctl next`, `playerctl status`, etc.

#### Multiple media players

By default `playerctl` sends commands to the first-available media player.
If you have multiple media players open at once, you can distinguish between them with the `--player` option, e.g.

```sh
# Pause media in VLC
playerctl --player=vlc pause

# Play media in Firefox
playerctl --player=firefox play
```
Useful: `playerctl --list-all` lists all active media players that can be controlled with `playerctl`.

Seriously, take 10 minutes and read `man playerctl`---you'll find more cool stuff, e.g. you can use the `playerctld` daemon to make `playerctl` send commands to the last-active player instead of the first-available player.

#### Using `playerctl` with `mpv`

The excellent [`mpv` media player](https://mpv.io/) requires the [`mpv-mpris` plugin](https://github.com/hoyon/mpv-mpris) to work with the MPRIS interface and `playerctl`.
Install the [`mpv-mpris` package](https://archlinux.org/packages/community/x86_64/mpv-mpris/) (`sudo pacman -S mpv-mpris`) and you should be able to control `mpv` like any other MPRIS-compatible media player e.g.
```
playerctl --player=mpv play-pause
```

### Key bindings for media controls

We'll do this using `xbindkeys`.
You need two pieces of information to define a key binding:

1. The X11 key symbol (keysym) of the key you want to bind.
   (`xbindkeys` identifies keyboard keys by their X11 keysym, which is, loosely, just a short code name for the key.)

1. The program you want to run when the key is pressed (e.g. `playerctl play-pause` for media control).
   You can then use `xbindkeys` to bind the keysym to the program.

#### Detect key symbols

You can identify X11 keysyms with the `xev` (X events) utility:
open a shell and run `xev`, type the key you wish to bind, and record the keysym.
Here is an example `xev` output for the `A` and `F10` keys on my ThinkPad T460 (I've highlighted the keysyms):

<div class="language-sh highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="c"># The keysym for the "A" key is "a"</span>
KeyPress event, serial 34, synthetic NO, window 0x2800001,
    root 0x7ad, subw 0x0, <span class="nb">time </span>682173681, <span class="o">(</span><span class="nt">-383</span>,347<span class="o">)</span>, root:<span class="o">(</span>909,369<span class="o">)</span>,
    state 0x0, keycode 38 <span class="o">(</span>keysym 0x61, <span class="ga">a</span><span class="o">)</span>, same_screen YES,
    XLookupString gives 1 bytes: <span class="o">(</span>61<span class="o">)</span> <span class="s2">"a"</span>
    XmbLookupString gives 1 bytes: <span class="o">(</span>61<span class="o">)</span> <span class="s2">"a"</span>
    XFilterEvent returns: False

<span class="c"># The keysym for the "F10/Search" key is "XF86Search"</span>
KeyPress event, serial 35, synthetic NO, window 0x2200001,
    root 0x79b, subw 0x0, <span class="nb">time </span>152154488, <span class="o">(</span><span class="nt">-581</span>,393<span class="o">)</span>, root:<span class="o">(</span>103,415<span class="o">)</span>,
    state 0x0, keycode 225 <span class="o">(</span>keysym 0x1008ff1b, <span class="ga">XF86Search</span><span class="o">)</span>, same_screen YES,
    XLookupString gives 0 bytes:
    XmbLookupString gives 0 bytes:
    XFilterEvent returns: False
</code></pre></div></div>
The keysyms are `a` and `XF86Search`.
You have to do a bit of digging through `xev`'s verbose output here; alternatively you could run `xev | grep keysym` to only print the keysym line.

#### Define key bindings in `.xbindkeysrc`

It's easy: first create the `~/.xbindkeysrc` configuration file; you can do this manually or run:

```sh
# Generate a default xbindkeys config file with commented-out examples
xbindkeys --defaults > ~/.xbindkeysrc
```
Then define key bindings in `xbindkeysrc` file with the general syntax:

```sh
# Place shell command in quotes and keysym on a new line
"SHELL-COMMAND"
  KEYSYM
```
Here is example:

```sh
# Use XF86Search for play/pause
"playerctl play-pause"
   XF86Search
```

This key binding will run the command `playerctl play-pause` whenever the key with keysym `XF86Search` (which happens to be `F10` on a ThinkPad T460; see `xev` output above)  is pressed.
You can probably take if from here and define key bindings for any `playerctl` commands that strike your fancy; consult `man playerctl` to see all available commands.

For more information and examples using `xbindkeys` see [ArchWiki: Xbindkeys](https://wiki.archlinux.org/title/Xbindkeys).

#### Activate key bindings

1. Run `xbindkeys` in a shell to activate the just-defined key bindings.

1. Make changes permanent: place the line `xbindkeys` above the line that starts your window manager or DE in your `~/.xinitrc` file, which will load key bindings each time you start X.
   Here is an example:

   ```sh
   # Activate X key bindings
   xbindkeys
 
   # Start the i3 window manager (or whatever WM or DE you use)
   exec i3
   ```
   See [ArchWiki: Xbindkeys/Making changes permanent](https://wiki.archlinux.org/title/Xbindkeys#Making_changes_permanent) for more information.

