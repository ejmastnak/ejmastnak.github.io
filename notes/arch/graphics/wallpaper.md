Goal: Set wallpaper to a given image on your file system, and make the background of your terminal slightly transparent so you can see the wallpaper a bit.

### Simple wallpaper
First call
```sh
feh --bg-scale '/path/to/image.jpg' 
```
This creates a `~/.fehbg` file, which is used for persistent wallpaper after reboot.

Add the following to `.xinitrc` (assuming you launch X with `startx`)
```
# Set wallpaper with feh
~/.fehbg &
```

### Transparent Alacritty background with i3

**Desired functionality:**
Set Alacritty window to TBD value and disable all other compositor features, e.g. blurring, fading, rounded corners, etc...

Reference: [ArchWiki: picom](https://wiki.archlinux.org/title/Picom)

Install `picom` and copy default config from `/etc` to `~/.config`
```sh
pacman -S picom
cp /etc/xdg/picom.conf 
```

Relevant part of `picom.conf`:
```conf
active-opacity            = 1;
inactive-opacity          = 1;
frame-opacity             = 1;
inactive-opacity-override = false;

opacity-rule = [
    "95:class_g = 'Alacritty' && focused",
    "80:class_g = 'Alacritty' && !focused"
];

blur-background = false;
shadow          = false
fading          = false
corner-radius   = 0
```

Find window class by running `xprop` and clicking on target window; then search for `WM_CLASS(STRING)`

If you wanted blurring you could use
```
backend = "glx";
glx-no-stencil = true;
blur-background = true;
blur-method = "dual_kawase";
blur-strength = 1;
```

Autostart on i3 with the following in i3 config
```
exec_always --no-startup-id picom -b
```

### Randomize wallpaper
The basic command is
```
DISPLAY=:0 feh --bg-scale --randomize ~/Pictures/wallpapers/*.jpg
```
You then just need to wrap this in a `systemd` timer.

Create e.g. `~/scripts/change-wallpaper.sh`, make it executable, and inside place
```
#!/bin/sh
DISPLAY=:0 feh --bg-scale --randomize ~/Pictures/wallpapers/*.jpg
```

Create e.g. `~/.config/systemd/change-wallpaper.service`
```
[Unit]
Description=Changes the wallpaper on X display :0
Wants=change-wallpaper.timer

[Service]
Type=oneshot
ExecStart=/bin/sh ~/scripts/change-wallpaper.sh

[Install]
WantedBy=graphical.target
```
And the corresponding timer `~/.config/systemd/change-wallpaper.timer`
```
[Unit]
Description=Changes the wallpaper on X display :0 every few minutes
Requires=change-wallpaper.service

[Timer]
OnActiveSec=1m
OnUnitActiveSec=1m

[Install]
WantedBy=timers.target
```
Then just `enable` and `start` the timer
