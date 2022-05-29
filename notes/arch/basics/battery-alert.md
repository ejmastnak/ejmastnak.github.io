---
title: Battery level alert on Arch Linux
---

# Battery level alert 

**Goal:** Create a desktop notification when battery falls below a threshold percentage of your choice.

**Motivation:** Remind you to charge your battery, which will happily drain completely if given the chance.
And then your laptop's dead, and you have to find a charger, reboot and restart all your programs, and who wants to do that?

**Reference:** [ArchWiki: Desktop notifications](https://wiki.archlinux.org/title/Desktop_notifications).

<div style="display: flex; justify-content: center; width: 100%;">
  <image src="/assets/images/arch/alert-battery.png" alt="Screenshot of battery alert." width="70%" />
</div>

## Procedure
<!-- vim-markdown-toc GFM -->

* [Set up a notification server](#set-up-a-notification-server)
  * [Do you need a notification server?](#do-you-need-a-notification-server)
* [Check battery level programmatically](#check-battery-level-programmatically)
* [Script with battery alert logic](#script-with-battery-alert-logic)
* [Create a notification service and timer](#create-a-notification-service-and-timer)
  * [Create battery alert service](#create-battery-alert-service)
  * [Create timer](#create-timer)
  * [Reload and start timer](#reload-and-start-timer)

<!-- vim-markdown-toc -->

First install the [`libnotify` package](https://archlinux.org/packages/extra/x86_64/libnotify/), which is a package for sending desktop notifications.

### Set up a notification server

Using `libnotify` requires a *notification server*.
Most standard desktop environments (DEs) have a built-in notification server; if you don't use a DE (e.g. you use only a window manager) you'll probably need to set up a standalone notification server. 

#### Do you need a notification server?

After installing `libnotify`, try running `notify-send "Hello, world!"` from the command line.
If this produces a "Hello, world!" notification (probably in the top right of your screen inside a white rectangle with rounded corners), you're good to go---skip to the next section.
No notification appearing? 
Then you need a standalone notification server---here's what to do:

1. Install the [`notification-daemon` package](https://archlinux.org/packages/community/x86_64/notification-daemon/)
1. Create the `/usr/share/dbus-1/services/` directory (if necessary), inside it create the file `org.freedesktop.Notifications.service`, and inside the file add the following:

   ```
   [D-BUS Service]
   Name=org.freedesktop.Notifications
   Exec=/usr/lib/notification-daemon-1.0/notification-daemon
   ```

After this a shell command like `notify-send "Hello world!"` should produce a visible GUI desktop notification.
Reference: [ArchWiki: Desktop notifications: standalone](https://wiki.archlinux.org/title/Desktop_notifications#Standalone).

### Check battery level programmatically

This is easiest using the built-in `acpi` command with the `-b` flag.
Here's an example `acpi` output for a discharging battery at 60% capacity:

```sh
$ acpi -b
Battery 0: Discharging, 60%, 03:54:00 remaining
```

<details>
  <summary>
  <strong>Bonus: </strong> View battery status through the <code class="language-plaintext highlighter-rouge">sysfs</code> file system
  </summary>

  <p>You can also interface with the battery using Linux’s <a href="https://en.wikipedia.org/wiki/Sysfs"><code class="language-plaintext highlighter-rouge">sysfs</code> file system</a>, which lives in the <code class="language-plaintext highlighter-rouge">/sys</code> directory.
  Battery information typically lives in the directory <code class="language-plaintext highlighter-rouge">/sys/class/power_supply/BAT0</code> (you might also have a <code class="language-plaintext highlighter-rouge">BAT1</code> directory if your laptop has two batteries installed).
  We’ll work with the following files within <code class="language-plaintext highlighter-rouge">/sys/class/power_supply/BAT0</code>:</p>

  <ul>
    <li>The <code class="language-plaintext highlighter-rouge">capacity</code> file holds current battery capacity in percentage.</li>
    <li>The <code class="language-plaintext highlighter-rouge">status</code> file holds the battery’s charging status (e.g. <code class="language-plaintext highlighter-rouge">Charging</code>, <code class="language-plaintext highlighter-rouge">Discharging</code>).</li>
  </ul>

  <p>You can check the battery and status programmatically by <code class="language-plaintext highlighter-rouge">cat</code>-ing the contents of a battery’s <code class="language-plaintext highlighter-rouge">sysfs</code> files.</p>

  <div class="language-sh highlighter-rouge"><div class="highlight"><pre class="highlight"><code><span class="c"># Example: a discharging battery at 60% capacity</span>
  <span class="nv">$ </span><span class="nb">cat</span> /sys/class/power_supply/BAT0/capacity
  <span class="o">&gt;</span> 60
  <span class="nv">$ </span><span class="nb">cat</span> /sys/class/power_supply/BAT0/status
  <span class="o">&gt;</span> Discharging
  </code></pre></div></div>
</details>

### Script with battery alert logic

I suggest using the script suggested in [ArchWiki: Laptop/Hibernate on low battery level](https://wiki.archlinux.org/title/Laptop#Hibernate_on_low_battery_level).
Place the script in any easily-accessible part of your file system; I use  `${HOME}/scripts/alert-battery.sh`.

The script uses `acpi` and `awk` to check if the battery is discharging and, if it is, if the battery capacity is less than the specified threshold.
If so, the script sends a desktop notification with `notify-send`.

```sh
#!/bin/sh
# You could place this script in e.g. `${HOME}/scripts/alert-battery.sh`

threshold=15  # threshold percentage to trigger alert

# Use `awk` to capture `acpi`'s percent capacity ($2) and status ($3) fields
# and read their values into the `status` and `capacity` variables
acpi -b | awk -F'[,:%]' '{print $2, $3}' | {
  read -r status capacity

  # If battery is discharging with capacity below threshold
  if [ "${status}" = Discharging -a "${capacity}" -lt ${threshold} ];
  then
    # Send a notification that appears for 300000 ms (5 min)
    notify-send -t 300000 "Charge your battery!"
  fi
}
```
Remember to make the script executable (e.g. `chmod +x alert-battery.sh`).

Try playing with the `threshold` value and running the script manually (e.g. `sh alert-battery.sh`)---you should get a "Charge your battery!" notification as long as your current battery capacity is below threshold.
(You could set `threshold=101` to guarantee a notification.)

The last step is to create a `systemd` unit to run the above script automatically.

### Create a notification service and timer

Plan: create a `systemd` user service to run `alert-battery.sh`, and then create a `systemd` timer to periodically run the service.
(It might be helpful to browse through [ArchWiki: systemd/User](https://wiki.archlinux.org/title/systemd/User) if it's your first time writing `systemd` units.)

#### Create battery alert service

Create the file `~/.config/systemd/user/alert-battery.service` and inside it paste

```systemd
[Unit]
Description=Desktop alert warning of low remaining battery

[Service]
Type=oneshot
# Change username and modify path to script as needed
ExecStart=/home/YOURUSERNAME/scripts/alert-battery.sh

[Install]
WantedBy=graphical.target
```

This service unit runs the `alert-battery.sh` script; setting the unit's `Type` to `oneshot` ensures the battery alert service completes before any other `systemd` units run; `Type=oneshot` is standard practice for units that start short-running shell scripts.
The `~/.config/systemd/user` directory is the standard location for user units.

#### Create timer

Create the file `~/.config/systemd/user/alert-battery.timer` and inside it paste
```systemd
[Unit]
Description=Check battery status every few minutes to warn the user in case of low battery
# Set `Requires` to the name of the battery alert service
Requires=alert-battery.service

# Define when and how the timer activates
[Timer]
# Start 1 minute after boot...
OnBootSec=1m
# ...and again every 5 minutes after `alert-battery.service` runs
OnUnitActiveSec=5m

[Install]
WantedBy=timers.target
```

The timer will run the `alert-battery.service` unit 1 minute after boot and then periodically every 5 minutes after `alert-battery.service` last activated.
See the `OPTIONS` section in `man 5 systemd.timer` for more on timer options.

<details>
  <summary>
  <strong>Note: </strong> Confusion around <code class="language-plaintext highlighter-rouge">OnUnitActiveSec</code>
  </summary>
  <p>There is some confusion online about using <code class="language-plaintext highlighter-rouge">OnUnitActiveSec</code> to periodically run <code class="language-plaintext highlighter-rouge">Type=oneshot</code> services.
  The theoretical problem is that <code class="language-plaintext highlighter-rouge">OnUnitActiveSec</code> runs relative to when the unit it triggers becomes active, but <code class="language-plaintext highlighter-rouge">Type=oneshot</code> units never become active—see e.g. <a href="https://github.com/systemd/systemd/issues/6680">.timer doesn’t fire #6680</a>.
  But the <code class="language-plaintext highlighter-rouge">OnUnitActiveSec</code> and <code class="language-plaintext highlighter-rouge">Type=oneshot</code> combination has worked well for me, and <a href="https://github.com/systemd/systemd/issues/21600">OnUnitActiveSec timer and Type=oneshot service #21600</a> rightly points out that the <code class="language-plaintext highlighter-rouge">OnUnitActiveSec</code> and <code class="language-plaintext highlighter-rouge">Type=oneshot</code> combination is used in official <code class="language-plaintext highlighter-rouge">systemd</code> examples.
  So I’m not sure if there is currently a problem or not.
  If anyone reading this knows the best-practice way to run a <code class="language-plaintext highlighter-rouge">Type=oneshot</code> service once at boot and periodically thereafter, please <a href="/notes/arch/basics/network-manager.html">let me know</a>!</p>
</details>

#### Reload and start timer

Use `deamon-reload` to tell `systemd` you've created new unit files, then start and enable the timer service:

```sh
systemctl --user daemon-reload
systemctl --user enable --now alert-battery.timer

# Optionally check that the timer is active
systemctl --user list-timers
```
Note that you only enable and start the `alert-battery.timer` unit and not the `.service` unit.
The battery alert system should be ready after this step.


Troubleshooting: If the timer fails to enable with a message along the lines of `Failed to enable unit: Unit file ~/.config/systemd/user/timers.target.wants/alert-battery.timer does not exist.`, just create the empty directory `~/.config/systemd/user/timers.target.wants/`.
Explanation: enabling units requires creating symlinks, and `systemctl` is complaining because the directory in which it would create a symlink does not exist yet.
Creating the directory solves the problem.
