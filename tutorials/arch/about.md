---
title: Arch Linux Post-Installation Configuration
date: 2022-04-29 19:15:09 -0400
date_last_mod: 2022-11-07 08:52:14 +0100
---

# Find Your Footing After Installing Arch Linux

**What you're reading:** Bite-sized, actionable tutorials to help you set up a functional work environment after a minimal install of Arch Linux.
The material should be applicable, with adjustments to package installation, to most `systemd`-based Linux distros.

**Purpose:** improve the transition and onboarding experience for new users.

<details>
  <summary>
  <strong>What about the ArchWiki?</strong> (click to expand)
  </summary>
  <p>I’ve tried to address the following issue:
  the ArchWiki, kind of like the Unix <code class="language-plaintext highlighter-rouge">man</code> pages, is the best place to go when you know what you’re doing and what you’re looking for,
  but can be intimidating to new users because of the sheer amount of information, the lack of strong opinions on how to approach a given topic, and the need to read multiple cross-linked articles before fully understanding a concept.</p>

  <p>This series is <em>intentionally</em> opinionated, and leans towards a minimalistic setup of the i3 window manager with the X Window System.
  It aims to make you quickly functional by teaching atomic tasks in self-contained, immediately actionable articles.</p>

  <p>Spending hours hopping through the ArchWiki’s cross-referenced articles is great—that’s how I learned myself—but in hindsight I’d argue that it’s not excessive hand-holding to first walk a new user through reliably connecting to the Internet, using their monitor, copying and pasting text, and confidently performing the handful of other basic, generally taken-for-granted tasks needed to find your footing on Arch Linux.</p>
</details>

**X11 Warning:** most of these tutorials involve the X window system in one form or another, so Wayland users may have to look elsewhere.

## Useful basics

[**Make Caps Lock useful**]({% link tutorials/arch/basics/caps2esc.md %})
<br>
Remap your Caps Lock key to Escape when pressed alone and Control when pressed in combination with other keys.
Your pinky will thank you.

[**Network**]({% link tutorials/arch/basics/network-manager.md %})
<br>
Connect to the Internet via WiFi or Ethernet using NetworkManager.

[**X Window System**]({% link tutorials/arch/basics/startx.md %})
<br>
Set up a minimal graphical environment using the Xorg display server and the i3 window manager.

[**USB**]({% link tutorials/arch/basics/usb.md %})
<br>
Read from, write to, and safely eject external USB drives.

[**Battery alert**]({% link tutorials/arch/basics/battery-alert.md %})
<br>
Get a desktop notification to *Charge your battery!* for low battery levels.

[**Copy and paste**]({% link tutorials/arch/basics/copy-paste.md %})
<br>
A unified clipboard experience across your GUI applications, the Alacritty terminal, and Vim.

[**Type faster**]({% link tutorials/arch/basics/typematic-rate.md %})
<br>
Change your typematic rate and typematic delay---basically make pressed-down keys repeat faster---in X and in the console.

## Graphics

[**Control laptop backlight brightness**]({% link tutorials/arch/graphics/backlight.md %})
<br>
Change your laptop's backlight brightness with your keyboard function keys.

[**External monitor I: First steps**]({% link tutorials/arch/graphics/displays.md %})
<br>
Make your display appear on an external monitor.

[**External monitor II: Hotplugging**]({% link tutorials/arch/graphics/monitor-hotplug.md %}) <br>
Automatically switch display to an external monitor after plugging in an HDMI or DisplayPort cable.

## Media

[**Media player control**]({% link tutorials/arch/media/playerctl.md %})
<br>
Play, pause, and skip music/videos system-wide with a single press of your keyboard.

[**Control volume**]({% link tutorials/arch/media/volume.md %})
<br>
Change audio volume with your keyboard function keys.

## Eye candy

[**Background wallpaper**]({% link tutorials/arch/graphics/wallpaper.md %})
<br>
Set your background wallpaper to an image of your choice, or to a slideshow of images.
Best served with transparent windows and `i3gaps`.

[**Transparent windows**]({% link tutorials/arch/graphics/picom.md %})
<br>
Use the `picom` compositor to make unfocused window backgrounds slightly transparent, so you can enjoy your background wallpaper.
