---
title: Keyboard shortcuts with xbindkeys on Linux
---

# Keyboard shortcuts with xbindkeys on Linux

**Goal:** Bind an arbitrary keyboard key to an arbitrary program in X.

**References:**
- [ArchWiki: Keyboard shortcuts/Xorg](https://wiki.archlinux.org/title/Keyboard_shortcuts#Xorg)
- List of [XF86 keyboard symbols](https://wiki.linuxquestions.org/wiki/XF86_keyboard_symbols)
- [ArchWiki: Xbindkeys](https://wiki.archlinux.org/title/Xbindkeys)

### What's involved

- Use `xbindkeys` 
- Keys in X11 are identified by their keyboard symbol ("keysym")


[ArchWiki: Keyboard shortcuts > Xorg](https://wiki.archlinux.org/title/Keyboard_shortcuts#Xorg) suggests using `acpid` when possible (e.g. as I did for controlling screen backlight), and if not `xbindkeys`.


### Detecting key codes
Use `xev` to show the keycode associated with a keyboard key.
You can then use `xbindkeys` to run commands in response to the key code.

Here is an example `xev` output for the `F9` and `F10` keys (the Tools and Search keys on my ThinkPad):
```
KeyPress event, serial 34, synthetic NO, window 0x2200001,
    root 0x79b, subw 0x0, time 152150379, (-581,393), root:(103,415),
    state 0x0, keycode 179 (keysym 0x1008ff81, XF86Tools), same_screen YES,
    XLookupString gives 0 bytes:
    XmbLookupString gives 0 bytes:
    XFilterEvent returns: False

KeyPress event, serial 35, synthetic NO, window 0x2200001,
    root 0x79b, subw 0x0, time 152154488, (-581,393), root:(103,415),
    state 0x0, keycode 225 (keysym 0x1008ff1b, XF86Search), same_screen YES,
    XLookupString gives 0 bytes:
    XmbLookupString gives 0 bytes:
    XFilterEvent returns: False
```

### Example: Media player control
Goal: Create key bindings that map keyboard function keys to play/pause toggle for current media player.

It's easy.
First create `~/.xbindkeysrc` or run `xbindkeys --defaults > ~/.xbindkeysrc` to create a default configuration file.

Then inside place, for example, something like
```sh
# Use XF86Search to play/pause MPV
"playerctl --player=mpv play-pause"
   XF86Search
```
This makes the `XF86Search` key (i.e. `F10` on a ThinkPad T460, keycode `225`, keysym `0x1008ff1b`; see `xev` output above) run the command `playerctl --player=mpv play-pause`.
For more see [https://wiki.archlinux.org/title/Xbindkeys](https://wiki.archlinux.org/title/Xbindkeys)

Final steps:
- Run `xbindkeys` in a shell for key bindings to become active.

- Place the line `xbindkeys` above the line that starts your window manager or DE in your `xinitrc`, so that key bindings are loaded when you start X.
