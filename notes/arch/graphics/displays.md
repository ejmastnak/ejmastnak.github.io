---
title: Connect laptop to an external monitor on Linux
---

# Connect laptop to an external monitor

**Goal:** understand how to make a laptop's internal display appear on an external monitor, then write shell script and `udev` rule to do this for you.

**Context:** you've just installed Arch, connect your laptop to an external monitor, and... nothing happens.
Blank monitor screen.

**Reference:** [ArchWiki: xrandr](https://wiki.archlinux.org/title/xrandr).

(This is part 1. Read [part 2]({% link /notes/arch/graphics/monitor-hotplug.md %}) for hot-plugging.)

## Procedure

Use the [xrandr utility](https://wiki.archlinux.org/title/xrandr).

First identify the names of all video outputs available on your computer.

```sh
xrandr

Screen 0: minimum 320 x 200, current 1920 x 1080, maximum 16384 x 16384

# The laptop's internal display (always connected)
eDP-1 connected primary (normal left inverted right x axis y axis)
  1920x1080     60.01 +  60.01    59.97    59.96    59.93
  1680x1050     59.95    59.88
  # and a long list of more available resolutions...

# The laptop's DisplayPort output (currently disconnected)
DP-1 disconnected (normal left inverted right x axis y axis)

# The laptop's HDMI output (currently connected)
HDMI-1 connected 1920x1080+0+0 (normal left inverted right x axis y axis) 527mm x 296mm
  1920x1080     60.00*   50.00    59.94
  1920x1080i    60.00    50.00    59.94
  # and a long list of more available resolutions...
```
The output names here are `eDP-1`, `DP-1`, and `HDMI-1`.
You might have multiple versions of outputs, e.g. `HDMI-1`, `HDMI-2`, etc.

Each of these entry should match a physical I/O port on your laptop.

You'll need to identify `xrandr` outputs to video ports.

TLDR: run `xrandr` with no cables connected, connect a cable, and run `xrandr` again.
Record which output changed from `disconnected` to `connected`.
Repeat as necessary.
In practice you only need the name of the physical I/O port you plan on using for connecting a monitor.

First run `xrandr` without any display cables connected to your laptop.
Only the internal display (`eDP-1` on my computer, YMMV) should be `connected`.

Now plug in an HDMI/DisplayPort/USB-C/whatever-else-you'll-use cable into whatever port you'll plan on using in practice.

Run `xrandr` again.
A new output should now be `connected`.

First step is to find the names of available output displays.

I used the `xrandr` command and got the following output names:
- `eDP-1` (internal display)
- `DP-1` (DisplayPort)
- `HDMI-1` (HDMI)

These all appear in `xrandr`'s output regardless of monitor status, and indeed show `connected` or `disconnected` as would be expected when I connect or disconnect ports.

My monitor's resolution is 1920x1080 by the way (based on manufacturer information). Some info about laptop's internal screen from `xrandr`:
```sh
Screen 0: minimum 320 x 200, current 1920 x 1080, maximum 16384 x 16384
eDP-1 connected primary (normal left inverted right x axis y axis)

[omitted: various other resolutions]
```

#### Toggling displays

For my purposes, relevant commands are
```sh
xrandr --output {name} --auto  # set resolution automatically
xrandr --output {name} --mode 1920x1080  # set resolution manually
xrandr --output {name} --off
```
Some examples:
```sh
xrandr --output DisplayPort-1 --auto
xrandr --output DisplayPort-1 --mode 1920x1080
xrandr --output eDP --off          # turn off laptop display
xrandr --output eDP --auto         # turn on laptop display
```
Workflow:
- Laptop may be powered on (hotplugging seems okay)
- Turn monitor off to be safe (but may not be necessary; hotplugging seems okay)
- Plug monitor input to laptop's DisplayPort output (in my case using an HDMI-DisplayPort adapter, which is irrelevant here)
- Turn monitor on
- Call the following commands
  ```sh
  xrandr --output DisplayPort-1 --auto
  xrandr --output eDP --off
  ```
  The first sends video output to `DisplayPort-1` and the second turns laptop screen off (to save energy).
- When ready to turn laptop back on:
  ```sh
  xrandr --output eDP --auto
  xrandr --output DisplayPort-1 --off
  ```
Note that graphics devices (e.g. the `eDP-1` outputed by `xrandr`) are listed in `/sys/class/drm/`.

#### Example script for toggling displays, 
Adapted from [ArchWiki: Toggle external monitor](https://wiki.archlinux.org/title/xrandr#Toggle_external_monitor)
```sh
#!/bin/bash
internal=eDP
external=DisplayPort-1

if xrandr | grep "${external} disconnected"; then
    xrandr --output "${external}" --off --output "${internal}" --auto
else
    xrandr --output "${internal}" --off --output "${external}" --auto
fi
```
