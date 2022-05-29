---
title: Remap Caps Lock to Escape and Control on Arch Linux
---

# Remap Caps Lock to Escape and Control

{% include arch-notes-header.html %}

**Goal:** use the `caps2esc` utility to make the Caps Lock key act like the Escape key when pressed alone and act like the Control key when pressed in combination with other keys.

**Motivation:** pleasant and ergonomic access system-wide to the very useful escape and control keys and a better Vim or Emacs experience.

**References:**
- [The caps2esc GitLab page](https://gitlab.com/interception/linux/plugins/caps2esc)
- [Ask Ubuntu: How do I install caps2esc?](https://askubuntu.com/questions/979359/how-do-i-install-caps2esc)


## Procedure

The `caps2esc` utility allows you to remap Caps Lock to Escape and Control at the level of the `libevdev` library---just above the kernel---so this solution works both in the Linux console and in a graphical session of the X Window System.
Here's what to do:

### Installation

Install the [`caps2esc` package](https://archlinux.org/packages/community/x86_64/interception-caps2esc/) from the Arch community repo:

```sh
# Install caps2esc
sudo pacman -S interception-caps2esc
```
This should also install the `interception-tools` package as a dependency.
The `interception-tools` package contains an input device monitoring program called `udevmon`, which we will use shortly to capture Caps Lock and Escape key presses.

### Configure `udevmon`

Create the configuration file `/etc/udevmon.yaml` (if necessary) and inside it add the following job:

```yaml
- JOB: "intercept -g $DEVNODE | caps2esc | uinput -d $DEVNODE"
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
```


<details>
  <summary>
  <strong>Explanation</strong> (click to expand)
  </summary>
  <p>This <code class="language-plaintext highlighter-rouge">udevmon</code> job runs the shell command <code class="language-plaintext highlighter-rouge">intercept -g $DEVNODE | caps2esc | uinput -d $DEVNODE</code> in response to presses of the Caps Lock and Escape keys, which are identified by the names <code class="language-plaintext highlighter-rouge">KEY_CAPSLOCK</code> and <code class="language-plaintext highlighter-rouge">KEY_ESC</code>;
  <code class="language-plaintext highlighter-rouge">udevmon</code> will set the <code class="language-plaintext highlighter-rouge">$DEVNODE</code> variable to the path of the matching device (a virtual file somewhere in the <code class="language-plaintext highlighter-rouge">/dev</code> directory) as needed.</p>

  <p>The shell command uses the <code class="language-plaintext highlighter-rouge">intercept</code> program to grab the Caps Lock or Escape key’s input device, pipes the key event to the <code class="language-plaintext highlighter-rouge">caps2esc</code> program (which implements the Caps Lock to Escape/Control logic), and then pipes the processed output back to a virtual key device using <code class="language-plaintext highlighter-rouge">uinput</code>.
  (You can read through <a href="https://gitlab.com/interception/linux/tools#how-it-works">Interception Tools/How it works</a> for details.)</p>
</details>

**Tip:** using `caps2esc` in the above `udevmon` job will make Caps Lock works as Escape and Control, and *also* make Escape work as Caps Lock.
If you want the Escape key to still behave as Escape, you can replace `caps2esc` with `caps2esc -m 1`, which uses the `caps2esc` "minimal mode" and leaves the Escape key unaffected (see `caps2esc -h` for documentation).

You now just need to start the `udevmon` program, which we will do using a `systemd` unit.

### A `systemd` unit for `udevmon`

Create the `systemd` unit file `/etc/systemd/system/udevmon.service` (if necessary) and inside it add the contents

```systemd
[Unit]
Description=udevmon
Wants=systemd-udev-settle.service
After=systemd-udev-settle.service

# Use `nice` to start the `udevmon` program with very high priority,
# using `/etc/udevmon.yaml` as the configuration file
[Service]
ExecStart=/usr/bin/nice -n -20 /usr/bin/udevmon -c /etc/udevmon.yaml

[Install]
WantedBy=multi-user.target
```
This service unit starts the `udevmon` program with very high priority (`nice` lets you set a program's scheduling priority; `-20` niceness is the highest possible priority).
Make sure the path to `uvdevmon` in the `ExecStart` line (e.g. `/usr/bin/udevmon`) matches the output of `which udevmon`.

Then enable and start the `udevmon` service:

```sh
# Enable and start the `udevmon` service
sudo systemctl enable --now udevmon.service

# Optionally verify the `udevmon` service is active and running
systemctl status udevmon
```
At this point you should be done---try using e.g. `<CapsLock>-L` to clear the terminal screen (like you would normally do with `<Ctrl>-L`).
If the `udevmon` service is enabled, the `udevmon` program should automatically start at boot in the future.

{% include arch-notes-footer.html %}
