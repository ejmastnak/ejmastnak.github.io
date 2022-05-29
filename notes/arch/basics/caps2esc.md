---
title: Remap Caps Lock to Escape and Control on Arch Linux
---

# Remap Caps Lock to Escape and Control

{% include arch-notes-header.html %}

**Goal:** make the Caps Lock key act like the Escape key when pressed alone and act like the Control key when pressed in combination with other keys.

**Motivation:** pleasant and ergonomic access system-wide to the very useful escape and control keys and a better Vim or Emacs experience.

**References:**
- [The caps2esc GitLab page](https://gitlab.com/interception/linux/plugins/caps2esc)
- [Ask Ubuntu: How do I install caps2esc?](https://askubuntu.com/questions/979359/how-do-i-install-caps2esc)


## Procedure

- Install the `caps2esc` package from the Arch community repo (see [Arch package link](https://archlinux.org/packages/community/x86_64/interception-caps2esc/))

  ```sh
  # Install caps2esc
  sudo pacman -S interception-caps2esc
  ```
  This should also install the `interception-tools` package as a dependency.
  Check the paths returned by `which caps2esc` and `which udevmon` for later use (`udevmon` comes with `interception-tools`).

- Create the file `/etc/udevmon.yaml` (if necessary) and inside it add the contents

  ```yaml
  - JOB: "intercept -g $DEVNODE | caps2esc | uinput -d $DEVNODE"
    DEVICE:
      EVENTS:
        EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
  ```

- Create the `systemd` unit file `/etc/systemd/system/udevmon.service` (if necessary) and inside it add the contents

  ```systemd
  [Unit]
  Description=udevmon
  Wants=systemd-udev-settle.service
  After=systemd-udev-settle.service

  # Use `nice` to start the `udevmon` program, using `/etc/udevmon.yaml` as the
  # configuration file, with very high priority (`nice -n -20`)
  [Service]
  ExecStart=/usr/bin/nice -n -20 /usr/bin/udevmon -c /etc/udevmon.yaml

  [Install]
  WantedBy=multi-user.target
  ```
  Ensure the path to `uvdevmon` in the `ExecStart` line (e.g. `/usr/bin/udevmon`) matches the output of `which udevmon`.

- Enable and start the `udevmon` service:

  ```sh
  sudo systemctl enable --now udevmon

  # Optionally verify the `udevmon` service status
  systemctl status udevmon
  ```
  At this point you should be done---try using e.g. `<CapsLock>-L` to clear the terminal screen (like you would normally do with `<Ctrl>-L`).

{% include arch-notes-footer.html %}
