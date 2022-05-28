---
title: Arch Linux Post-Installation Configuration
---

# Find Your Footing After Installing Arch Linux

**What you're reading:** Bite-sized tutorials to help you set up a functional work environment after a minimal install of Arch Linux
(read: mostly solutions to all my stumbling points when migrating to Arch from macOS).
The material should be applicable, with adjustments to package installation, to most `systemd`-based Linux distros.

**Purpose:** lower the barrier to entry and improve the transition experience for new users.

**X11 Warning:** most tutorials involve the X window system in one form or another, so Wayland users may have to look elsewhere.
Use the i3 window manager and the Alacritty terminal if you want to follow along exactly, but most of these tutorials should work fine on an X-based setup.

## Useful basics

[**Make Caps Lock useful**]({% link notes/arch/basics/caps2esc.md %})
<br>
Remap your Caps Lock key to Escape when pressed alone and Control when pressed in combination with other keys.
Your pinky will thank you.

[**Network**]({% link notes/arch/basics/network-manager.md %})
<br>
Connect to the Internet via WiFi or Ethernet using NetworkManager.

[**X Window System**]({% link notes/arch/basics/startx.md %})
<br>
Set up a minimal graphical environment using the Xorg display server and the i3 window manager.

<!-- [**USB**]({% link notes/arch/basics/usb.md %}) -->
<!-- <br> -->
<!-- Read and write data from external USB drives. -->

[**Battery alert**]({% link notes/arch/basics/battery-alert.md %})
<br>
Get a desktop notification to *Charge your battery!* for low battery levels.

[**Copy and paste**]({% link notes/arch/basics/copy-paste.md %})
<br>
A unified clipboard experience across your GUI applications, the Alacritty terminal, and Vim.

[**Type faster**]({% link notes/arch/basics/typematic-rate.md %})
<br>
Change your typematic rate and typematic delay---basically make pressed-down keys repeat faster---in X and in the console.

## Graphics

[**Control laptop backlight brightness**]({% link notes/arch/graphics/backlight.md %})
<br>
Change your laptop's backlight brightness with your keyboard function keys.

[**External monitor I: First steps**]({% link notes/arch/graphics/displays.md %})
<br>
Make your display appear on an external monitor.

[**External monitor II: Hotplugging**]({% link notes/arch/graphics/monitor-hotplug.md %}) <br>
Automatically switch display to an external monitor after plugging in an HDMI or DisplayPort cable.

## Media

[**Media player control**]({% link notes/arch/media/playerctl.md %})
<br>
Play, pause, and skip music/videos system-wide with a single press of your keyboard.

[**Control volume**]({% link notes/arch/media/volume.md %})
<br>
Change audio volume with your keyboard function keys.

## Eye candy

[**Background wallpaper**]({% link notes/arch/graphics/wallpaper.md %})
<br>
Set your background wallpaper to an image of your choice, or to a slideshow of images.
Best served with transparent windows and `i3gaps`.

[**Transparent windows**]({% link notes/arch/graphics/picom.md %})
<br>
Use the `picom` compositor to make unfocused window backgrounds slightly transparent, so you can enjoy your background wallpaper.
