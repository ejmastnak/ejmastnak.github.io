---
title: Adjust volume on Arch Linux
---

# Volume adjustment on Arch Linux

**Goal:** understand how to programmatically adjust audio playback volume from the command line, then create convenient key bindings to do this for you.

**Read this if:** your laptop has two keyboard functions keys for increasing and decreasing audio volume, but these keys have no effect on your volume after a standard install of Arch.

**References:**
- [ArchWiki: acpid](https://wiki.archlinux.org/title/Acpid)
- [ArchWiki: ALSA](https://wiki.archlinux.org/title/Advanced_Linux_Sound_Architecture)

(Note: this page closely parallels my guide to [controlling a laptop's backlight brightness]({% link notes/arch/graphics/backlight.md %}), since both rely `acpid` to set key bindings.)

## Adjust volume from a shell

The Arch Linux sound system has multiple levels.
See [ArchWiki: Sound System/General information](https://wiki.archlinux.org/title/sound_system#General_information).
There are low-level drivers and APIs (ALSA)
and optionally sound server. 
Common sound servers are PulseAudio (`pulseaudio` package), PipeWire (`pipewire` package), and JACK (`jack2` package).
PulseAudio is probably the most common.

You can control volume either through ALSA or through a sound server.
Controlling volume through ALSA (more low level) can work badly if you also have a sound server installed.

From Wikipedia:

> A sound server is software that manages the use of and access to audio devices (usually a sound card). It commonly runs as a background process. 

The choice depends on whether you have

- No PulseAudio: use `amixer`
- PulseAudio: use `pactl` 
- PulseAudio: install `pulseaudio-alsa` and use `amixer` (works for me; the Internet suggests results may vary)

Plan: first show how to adjust volume from a command-line shell, then set up key bindings to do this automatically.

We'll use ALSA (the Advanced Linux Sound Architecture) for the audio portion of this guide.
ALSA provides sound card drivers that allow the Linux kernel (software) to communicate with your sound card (hardware);
ALSA will be installed on any Arch system by default, so you shouldn't need to do any manual installation.

You *should* install the [`alsa-utils`](https://archlinux.org/packages/extra/x86_64/alsa-utils/) package, which provides the `amixer` program.

What's involved: "controls" and "simple controls"---a software abstraction over hardware "controls".

```sh
$ amixer scontrols
Simple mixer control 'Master',0
Simple mixer control 'Headphone',0
Simple mixer control 'Headphone',1
Simple mixer control 'Speaker',0
```

We'll be interested in the `Master` simple control.

You can do like
```sh
amixer set Master 50%
amixer set Master 10%+
amixer set Master 10%-

amixer set Master mute
amixer set Master unmute
amixer set Master toggle
```

Worth noting: the `set` command measures percentage in "raw" volume by default.
Pass the `-M` option to use human-perceived volume.
See the `OPTIONS` section in `man amixer` for details.

Try changing the volume of the `MASTER` control and listen for a physical changein audio.

Seriously---take 5 minutes and look through `man amixer`, it's concise and helpful.
And see [Stack Exchange: How to use command line to change volume?](https://unix.stackexchange.com/a/21090) for a summary of commands you might use in practice.


**Check-in point:** At this point you should be able to change the `MASTER` control's volume level by issuing `amixer set Master` commands from a shell, and you should be able to hear the corresponding change in physical volume.

## Convenient key mappings for volume control

We'll set up volume key bindings using the [`acpid` daemon](https://wiki.archlinux.org/title/Acpid).

If you're a new user, I've just introduced two potentially unfamiliar bits of jargon.
For our purposes, here is what they mean:

- ACPI (which stands for Advanced Configuration and Power Interface) is a standard interface that gives your operating system a way to interact with your hardware (e.g. your backlight and function keys in our context).
  Reference: [Wikipedia: ACPI](https://en.wikipedia.org/wiki/Advanced_Configuration_and_Power_Interface).

- A daemon (at the risk of stating the obvious) is a computer program that runs as a background process, and typically listens for and responds to events, e.g. network requests or hardware activity.
  In our context, we'll use the `acpid` daemon to detect and respond to ACPI events resulting from brightness key presses.
  References: [Wikipedia: Daemon (computing)](https://en.wikipedia.org/wiki/Daemon_(computing)) in general; [ArchWiki: acpid](https://wiki.archlinux.org/title/Acpid) and `man 8 acpid` in our context.

### Installation

You'll need the `acpid` package installed---check if it's already installed with `pacman -Q acpid` and install it if necessary.
Then enable and start the `acpid` daemon if necessary.

```sh
# Install the acpid package (if necessary)
sudo pacman -S acpid

# Check if the acpid daemon is enabled and active
systemctl status acpid.service

# Enable and start the acpid daemon (if necessary)
systemctl enable --now acpid.service
```

The `acpid` daemon will then listen for ACPI events.

### The ACPI event workflow

ACPI events (e.g. function key presses, closing your laptop lid, plugging in a computer charger, etc.) are managed using text files in the directory `/etc/acpi/events/`.
Each event file must define an ACPI event and an action to take in response to the event.
These event files use a key value syntax of the form:

```sh
# Comments are allowed on new lines
event=<ACPI-event-regex>
action=<shell-command>
```
The `event` key's value should be a regular expression matching the name(s) of ACPI event(s),
and the `action` key's value should be a valid shell command, which will be invoked by `/bin/sh` whenever an ACPI event matching the `event` key's value occurs.

By default, the directory `/etc/acpi/events/` contains a single file, called `anything`, with the following contents:

```sh
# Pass all events to our one handler script
event=.*
action=/etc/acpi/handler.sh %e
```
This generic `anything` file catches all ACPI events using the `event=.*` (note the `.*` catch-all regex).
The event's name, accessed using the `%e` macro, is then passed as an argument to the default event handler script `/etc/acpi/handler.sh`.

### Key bindings and event handler for volume control

Here's the recipe we'll use:

- Identify the name and label of a targeted ACPI event (e.g. pressing your volume keys)
- Create a shell script in `/etc/acpi/handlers` to perform an action in response to the ACPI event (e.g. adjust your volume)
- Create a text file in `/etc/acpi/events` to register the ACPI event and run the handling shell script in response.

Reference: [ArchWiki: Acpid > Enabling volume control](https://wiki.archlinux.org/title/Acpid#Enabling_volume_control).

#### Identify event names

First run the `acpi_listen` event listener from a command line and identify its output in response to brightness key presses.
In my case:

```sh
$ acpi_listen
# *presses brightness up and brightness down keys* (F5 and F6 on my laptop)
video/brightnessup BRTUP 00000086 00000000
video/brightnessdown BRTDN 00000087 00000000
```
Record the event names (`video/brightnessup` and `video/brightnessdown`) and corresponding labels (`BRTUP` and `BRTDN`).

#### Create an event handler script

Create the following shell script to handle `brightnessup` and `brightnessdown` events.
I've named it `backlight.sh` and placed it in the conventional location `/etc/acpi/handlers`, but you could name it anything you like and probably place it in any readable location on your file system.

```sh
#!/bin/sh
# Location: /etc/acpi/handlers/backlight.sh
# A script to control backlight brightness with ACPI events
# Argument $1: either '-' for brightness up or '+' for brightness down

# Path to the sysfs file controlling backlight brightness
brightness_file="/sys/class/backlight/intel_backlight/brightness"

# Step size for increasing/decreasing brightness.
# Adjust this to a reasonable value based on the value of the file
# `/sys/class/backlight/intel_backlight/max_brightness` on your computer.
step=20

# Some scary-looking but straightforward Bash arithmetic and input/output redirection
case $1 in
  # Increase current brightness by `step` when `+` is passed to the script
  +) echo $(($(< "${brightness_file}") + ${step})) > "${brightness_file}";;

  # Decrease current brightness by `step` when `-` is passed to the script
  -) echo $(($(< "${brightness_file}") - ${step})) > "${brightness_file}";;
esac
```
This script (taken from [ArchWiki: Acpid > Enabling backlight control](https://wikiarchlinux.org/title/Acpid#Enabling_backlight_control)) takes one parameter, which should be either `+` or `-`, and either increases (if `+` is passed) or decreases (if `-` is passed) the current backlight brightness by the value of the `step` variable.

Make the handler script executable:

```sh
sudo chmod +x /etc/acpi/handlers/backlight.sh
```

#### Create event-matching files

Create the event files `/etc/acpi/events/BRTUP` and `/etc/acpi/events/BRTDN` (using the event labels is not necessary; you can use whatever alphanumeric characters you want that obey the naming conventions in the second paragraph of `man acpid`).
Inside the files place:

```sh
# (Adjust path to the `backlight.sh` script as needed)

# Inside /etc/acpi/events/BRTUP
event=video/brightnessup
action=/etc/acpi/handlers/backlight.sh +

# Inside /etc/acpi/events/BRTDN
event=video/brightnessdown
action=/etc/acpi/handlers/backlight.sh -
```

Reboot. The backlight keys should then change backlight brightness.

Speaking from personal experience: if the backlight keys aren't working after a reboot, double-check the handler script and event files for typos and ensure the handler script is executable (and make sure you've passed both "Check-in points" in the previous section).
There's a lot of moving parts here and even a small typo can prevent things from working.

## Troubleshooting: fix failed loading of `acpi_video0` with dual graphics

(Probably irrelevant to most users, but I thought I'd include it after going through the problem myself.)

Context: after installing Arch on a MacBookPro with dual graphics (integrated Intel graphics and discrete AMD GPU), the `acpi_video0/` directory initially failed to appear inside `/sys/class/backlight`.
Also relevant: my start-up log when booting into Arch included the message:

```sh
[FAILED] Failed to start `Load/Save Screen Backlight Brightness of backlight:acpi_video0.`
See `systemctl status systemd-backlight@backlight:acpi_video0.service` for details.
```

Solution: I got the `acpi_video0` directory to appear in `/sys/class/backlight` (and also eliminated the boot-up error message), by adding the kernel parameter `acpi_backlight=video` (as suggested in [ArchWiki: Backlight/Kernel command-line options](https://wiki.archlinux.org/title/backlight#Kernel_command-line_options)) to my boot configuration.

To add pass the `acpi_backlight=video` parameter to the Linux kernel, *assuming you are using* [`systemd-boot`](https://wiki.archlinux.org/title/systemd-boot) *as your boot loader*, edit the file `/boot/loader/arch.conf`, and make the following change:

```sh
# To your current kernel parameters, for example...
options root=/dev/sdaXYZ rw                          # before

# ...append `acpi_backlight=video`
options root=/dev/sdaXYZ rw acpi_backlight=video     # after
```

(Or, for a one-time test, type `e` in the `systemd-boot` boot screen when logging in, and add `acpi_backlight=video` to the kernel parameters.) 

For adding kernel parameters with other boot loaders, consult [ArchWiki: Kernel parameters](https://wiki.archlinux.org/title/Kernel_parameters).


### PulseAudio

or through `pactl`, which requires the PulseAudio sound server.
Install with the [`pulse-audio`](https://archlinux.org/packages/extra/x86_64/pulseaudio/) package.
Note that `pactl` is owned by `libpulse`, which is required by `pulseaudio`.

Helpful: `pactl list sinks`

```sh
# Get current volume
pactl get-sink-volume @DEFAULT_SINK@

# Set/increase/decrease volume
pactl set-sink-volume @DEFAULT_SINK@ 50%  # set volume to 50% of maximum
pactl set-sink-volume @DEFAULT_SINK@ +5%  # increase current volume by 5%
pactl set-sink-volume @DEFAULT_SINK@ -5%  # decrease current volume by 5%

# Audio mute
pactl set-sink-mute @DEFAULT_SINK@ toggle

# Mic mute
pactl set-source-mute @DEFAULT_SOURCE@ toggle
```

Jargon:
- sink is an audio output device (e.g. built-in speaker, headphones, etc.)
- source is a source of audio (e.g. a microphone)

From the [PulseAudio documentation](https://www.freedesktop.org/wiki/Software/PulseAudio/About/):

> PulseAudio clients can send audio to "sinks" and receive audio from "sources".
