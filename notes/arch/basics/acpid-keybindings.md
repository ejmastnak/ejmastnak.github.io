Goal: run programs in response to ACPI events, such as certain key presses and e.g. opening/closing lid.

## Contents
<!-- vim-markdown-toc GFM -->

* [What's involved:](#whats-involved)
* [Finding event labels](#finding-event-labels)
* [Example: Key bindings for backlight control](#example-key-bindings-for-backlight-control)

<!-- vim-markdown-toc -->

The Advanced Configuration and Power Interface (ACPI) specification allows an operating system to configure hardware components.

Reference: [https://wiki.archlinux.org/title/Acpid](https://wiki.archlinux.org/title/Acpid)

Install the `acpid` package and enable `acpid.service`

### What's involved:
Reference: `man acpid`

- `acpid` is a daemon used to execute programs in response to ACPI events (key presses, battery plugged in, closing the lid, basically hardware stuff)

- ACPI events are managed using text files in `/etc/acpi/events/`.
  
  Each event file must define an event and an action using a key-value syntax, e.g. `event=<event>` and `action=<action>`.
  
  The event's value is treated as a regular expression.

  The action's value should be a shell command, and is invoked by `/bin/sh` whenever an ACPI event matching the `event` key's value occurs.
  
- By default, `/etc/acpi/events/` contains a single file, called `anything`, with the following contents:
  ```sh
  # Pass all events to our one handler script
  event=.*
  action=/etc/acpi/handler.sh %e
  ```
  This file catches all ACPI events using the wildcard `event=.*`.
  The event's name (or *label*) is then passed to the default event handler script `/etc/acpi/handler.sh`.

### Finding event labels
Reference: [https://wiki.archlinux.org/title/Acpid#Configuration](https://wiki.archlinux.org/title/Acpid#Configuration)

To find out the labels of buttons associated with acpid events on your computer:

Using `acpi_listen`:
1. `sudo acpi_listen`
2. Trigger an event you want the label of. Example output for me for brightness up/down:
   ```
   video/brightnessup BRTUP 00000086 00000000
   video/brightnessdown BRTDN 00000087 00000000
   ```
3. Exit with `<Ctrl>c`

Understanding: The four columns in the output of `acpi_listen` are sent to `/etc/acpi/handler.sh` as the arguments `$1`, `$2`, `$3`, and `$4`.
  
See [https://wiki.archlinux.org/title/Acpid#Alternative_configuration](https://wiki.archlinux.org/title/Acpid#Alternative_configuration) for a single-file-per-acpid-event workflow, instead of having all event handling in `/etc/acpi/handler.sh` as by default.

Alternatively, use `journalctl -f` to list events.
Example output for brightness up/down
```
ACPI group/action undefined: video/brightnessdown / BRTDN
ACPI group/action undefined: video/brightnessup / BRTUP
```
Note that not all keys are associated with ACPI events, for example the `F9` and `F10` media keys do not produce a response with `apci_listen`.

### Example: Key bindings for backlight control
Reference: [ArchWiki: Acpid > Enabling backlight control](https://wiki.archlinux.org/title/Acpid#Enabling_backlight_control)

- Find the output of `sudo acpi_listen` in response to brightness key presses.
  In my case:
  ```
  video/brightnessup BRTUP 00000086 00000000
  video/brightnessdown BRTDN 00000087 00000000
  ```
  Each line will be passes as four (space-delimited) arguments to the ACPI handler script you use, just so you know what `$1`, `$2`, `$3`, and `$4` are later.

- Create `/etc/acpi/events/BRTUP` and `/etc/acpi/events/BRTDN` (or whatever alphanumeric characters you want; see second paragraph of `man acpid` for name conventions)
  ```sh
  # /etc/acpi/events/BRTUP
  event=video/brightnessup
  action=/etc/acpi/handlers/backlight.sh +
  ```
  Analogous for `BRTDN`.

- This is for use with the script
  ```sh
  #!/bin/sh
  # Location: /etc/acpi/handlers/backlight.sh
  # A script to control backlight brightness with ACPI events
  # Argument $1: either '-' or '+' for brightness up or down

  backlight_dir="/sys/class/backlight/intel_backlight"

  # Step size for increasing/decreasing brightness
  # Note that maxbrightness on this machine is 852
  step=10

  case $1 in
    -) echo $(($(< "${backlight_dir}/brightness") - ${step})) > "${backlight_dir}/brightness";;
    +) echo $(($(< "${backlight_dir}/brightness") + ${step})) > "${backlight_dir}/brightness";;
  esac
  ```
- Make the handler executable
  ```sh
  sudo chmod +x /etc/acpi/handlers/backlight.sh
  ```
- Reboot. The backlight keys should then change backlight brightness.
