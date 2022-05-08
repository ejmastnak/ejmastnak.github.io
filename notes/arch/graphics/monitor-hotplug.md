Goal: detect when monitor cable is connected or disconnected, and use `xrandr` to send display to monitor or laptops' internal display accordingly.

## Contents
<!-- vim-markdown-toc GFM -->

* [Hotplug](#hotplug)
* [Hotplug script](#hotplug-script)
* [Solution with `udev` rules and `systemd` units](#solution-with-udev-rules-and-systemd-units)

<!-- vim-markdown-toc -->

### Hotplug
Diagnostics: `udevadm monitor` will show if `udev` detects display cable hotplugging.
For orientation...
```sh
udevadm monitor will print the received events for:
UDEV - the event which udev sends out after rule processing
KERNEL - the kernel uevent
```
Run `udevadm monitor`, plug your HDMI/DisplayPort cable in and out, and look for output to the console.
For example, in my case:
```sh
KERNEL[407.784817] change   /devices/pci0000:00/0000:00:02.0/drm/card0 (drm)
UDEV  [407.845413] change   /devices/pci0000:00/0000:00:02.0/drm/card0 (drm)
KERNEL[411.413834] change   /devices/pci0000:00/0000:00:02.0/drm/card0 (drm)
UDEV  [411.424828] change   /devices/pci0000:00/0000:00:02.0/drm/card0 (drm)
```
Potential problem (in my own words, probably not precise): udev rule is triggered before external monitor is added to `xrandr`'s control.
This problem is solved by using `systemd`, described below.

Note: HDMI connection status is listed in `/sys/class/drm/card0-HDMI-A-{1|2|3|...}/status`

### Hotplug script
The script implementing hotplug logic can be something like:
```sh
#!/bin/bash
internal=eDP-1
external=HDMI-1

# If external display was just physically disconnected, turn xrandr output
# for external display off and turn internal display on.
if xrandr | grep "${external} disconnected";
then
    xrandr --output "${external}" --off --output "${internal}" --auto

# If external display was just physically connected, turn xrandr output
# for external display on and turn internal display off.
else
    xrandr --output "${internal}" --off --output "${external}" --auto
fi
```
You can also test the script is being run by adding a line like `date >> /home/ej/test-hotplug.txt`.

### Solution with `udev` rules and `systemd` units
For context and motivation see https://bbs.archlinux.org/viewtopic.php?id=170294

Create a `udev` rule in `/etc/udev/rules.d/85-drm-hotplug.rules` with the following contents:
```
ACTION=="change", KERNEL=="card0", SUBSYSTEM=="drm", RUN+="/usr/bin/systemctl start hotplug-monitor.service"
```
Create the `systemd` unit `/etc/systemd/system/hotplug-monitor.service` with the following contents
```
[Unit]
Description=Monitor hotplug

[Service]
Type=simple
RemainAfterExit=no
User=<your-username>
ExecStart=/usr/local/bin/hotplug-monitor.sh

[Install]
WantedBy=multi-user.target
```
Replace the `User=<your-username>` field with your username.
Run `systemctl daemon-reload` to make `systemctl` register the new service file.
No need to enable or start the service manually---it will started as needed from the above `udev` rule.

Finally implement hotplug and display-switching logic in the shell script `/usr/local/bin/hotplug-monitor.sh` with the (for example) following contents
```sh
#!/bin/bash

# Setting environment variables
X_USER=<your-username>
export DISPLAY=:0
export XAUTHORITY=/home/$X_USER/.Xauthority
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus

# Display names recogized by xrandr
internal=eDP-1
external=HDMI-1

# If external display was just physically connected, turn
# external display on and turn internal display off.
if [ $(cat /sys/class/drm/card0-HDMI-A-1/status) == "connected" ];
then
  xrandr --output "${internal}" --off --output "${external}" --auto

# If external display was just physically disconnected, turn 
# external display off and turn internal display on.
elif [ $(cat /sys/class/drm/card0-HDMI-A-1/status) == "disconnected" ];
then
  xrandr --output "${external}" --off --output "${internal}" --auto
else 
  exit
fi
```
Replace `<your-username>` with your username.
Notice that the environment variables `DISPLAY` and `XAUTHORITY` must be set; `:0` is a standard value and `/home/<your-username>/.Xauthority` is just the path to the user's `.Xauthority` file.
