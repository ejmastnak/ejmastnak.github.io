---
title: Arch Linux Post-Installation Configuration
---

# Find Your Footing After Installing Arch Linux

**What you're reading:** Bite-sized, actionable tutorials to help you set up a functional work environment after a minimal install of Arch Linux.
<!-- (read: mostly solutions to my stumbling points when migrating to Arch from macOS). -->
The material should be applicable, with adjustments to package installation, to most `systemd`-based Linux distros.

**Purpose:** improve the transition and onboarding experience for new users.

<details>
  <summary>
  <strong>What about the ArchWiki?</strong> (click to expand)
  </summary>
  <p>TLDR: The ArchWiki is the canonical resource for Arch-related information, 
  while these guides are my attempt to distill information from the ArchWiki, Arch forums, and my personal experience into self-contained, immediately actionable guides more friendly to new users.</p>

  <p>Longer version: I’ve tried to address the following issue:
  the ArchWiki, like the Unix <code class="language-plaintext highlighter-rouge">man</code> pages, is the best and fastest place to go when you know what you’re doing and what you’re looking for,
  but can be intimidating to new users because of the sheer amount of information, lack of strong opinions on how to approach a given topic, and the need to read multiple cross-linked articles before fully understanding a concept.</p>

  <p>This series is <em>intentionally</em> opinionated, and leans towards a minimalistic setup of the i3 window manager with the X Window System.
  It aims to make you quickly functional by teaching atomic tasks in self-contained articles;
  I try to cover only the information you need to solve each task (while still understanding what you’re doing), and move supplemental information to external references.
  Individual articles are meant to be self-contained and immediately actionable.</p>

  <p>Spending hours hopping through the ArchWiki’s cross-referenced articles is great—that’s how I learned myself—but in hindsight I’d argue that it’s not excessive hand-holding to first walk a new user through reliably connecting to the Internet, using their monitor, copying and pasting text, and confidently performing the handful of other basic, generally taken-for-granted tasks needed to find your footing on Arch Linux.</p>
</details>

**X11 Warning:** most of these tutorials involve the X window system in one form or another, so Wayland users may have to look elsewhere.
Use the i3 window manager and the Alacritty terminal emulator if you want to follow along exactly, but most of these tutorials should work fine on any X-based setup.

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
