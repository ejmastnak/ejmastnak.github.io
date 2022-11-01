---
title: USB drives on Arch Linux
date: 2022-04-29 19:15:09 -0400
date_last_mod: 2022-10-27 20:29:46 +0200
---

# Using USB drives on Arch

{% include arch-notes-header.html %}

{% include date.html %}

**Goal:** Explain what you need to do to read from and write to external USB drives;
explain how to safely eject USB drives.

**References:**
- [ArchWiki: USB storage devices](https://wiki.archlinux.org/title/USB_storage_devices)
- [ArchWiki: Udisks](https://wiki.archlinux.org/title/Udisks)
- [ArchWiki: File systems](https://wiki.archlinux.org/title/file_systems)
- The `man` pages for `lsblk`, `mount`, `umount`, `udisksctl`, and `udisks`

To interact with the files on a USB drive from your computer, you have to mount the file system stored on the USB drive's data partition onto a dedicated *mount point* on your computer's file system (Windows/macOS and most desktop environments usually do this for you).

You can mount drives manually or automate the process with an auxiliary program.
In practice most people will auto-mount, but you'll probably learn something if you go through the manual process at least a few times first.

## Mount a drive manually

Here's how to mount a USB drive manually:

### Detect the USB drive's block device name

You'll first need the block device names identifying your USB drive and its data partition.
(A USB drive is classified as a *block device* because data is written to and read from the drive in fixed-sized blocks.)

**TLDR:** plug in the USB drive and use `lsblk` to identify (1) the USB drive and (2) its data partition, which might look something like (1) `sdb` and (2) `sdb1`.
You can now [jump to the next section](#mount-the-usb-drive).

Here's what to do in more detail:

1. Before plugging your USB drive into your computer, run the `lsblk` ("list block devices") command from a shell to list the names of currently available block devices.
   The idea is to get a picture of available block devices *before* inserting your USB drive to make it easy to see the changes that occur *after* plugging the USB drive in.

1. Plug in your USB drive and wait a moment or so for your OS to detect it.
1. Run `lsblk` again.
   You should see a new entry (often `sdb`), which identifies your USB drive,
   and some numbered entries (e.g. `sdb1`, `sdb2`) below it---the numbered entries identify partitions on the USB drive.
   (It might help to orient yourself using the size of each block device and partition, since you presumably know beforehand how large your USB drive is.)

   Troubleshooting: if the drive does not appear in `lsblk` try rebooting your computer---I've sometimes had this problem when I forgot to reboot after updating the operating system kernel.

```bash
$ lsblk 
# Before             # After
NAME                 NAME
sda                  sda
├─sda1               ├─sda1
├─sda2     ---->     ├─sda2
├─sda3               ├─sda3
└─sda4               └─sda4
                     sdb       <-- USB drive
                     └─sdb1    <-- USB drive data partition
```
   
You'll want to **identify two things**:

1. The USB drive's identifier (e.g. `sdb` or `nvme0n1`).
   I'll use `sdX` to avoid the risk of you blindly copying `sdb`, which could be something different on your computer---replace the `X` with the appropriate letter on your system (which may still be `b`).

1. The identifier of the drive's data partition, which will be the drive identifier followed by an integer number (e.g. `sdb1` or `nvme0n1p1`).
   The data partition should be the partition whose size roughly matches your USB drive's memory capacity.
   I'll use `sdXN`---replace the `N` with the number on your computer.

Remember these identifiers for later.

### Mount the USB drive

A mount point is a location on one file system from which you interact with a second file system;
for our purposes, a mount point is the directory on your computer's file system at which you will load and interact with the files on the USB drive.
<!-- (Note that the USB drive's files are not copied to the mount directory---the directory only serves as an access point.) -->

Mount points are conventionally located inside the `/mnt` directory---you should first **create a directory inside `/mnt` to use as a USB mount point**.
You can name it whatever you want; I'll use the generic `/mnt/usbdrive`

```bash
# Create a mount point for the USB drive.
# You'll need sudo privileges because /mnt is on the root partition.
sudo mkdir /mnt/usbdrive  # replace 'usbdrive' with whatever you like
```

You only need to create the mount directory once---it will stay on your file system and you can reuse it later as a mount point whenever you use a USB drive.

You can then **mount the drive's data partition to the mount directory** using the `mount` command:

```bash
# Mount the USB drive by specifying its entry in the `/dev` directory.
# Replace `sdXN` with the data partition identifier shown by `lsblk`, e.g. `sdb1`
sudo mount /dev/sdXN /mnt/usbdrive
```

Check that the drive is properly mounted using `lsblk`---the `MOUNTPOINTS` column for the drive's data partition entry should now show `/mnt/usbdrive` (or whatever mountpoint you used).

At this point you can **interact with the files on the USB drive from the mount directory on your computer's file system**, reading/writing/copying just like with any other directory (but note that you'll need root privileges to write to the drive if it's mounted in `/mnt`).

Troubleshooting: if reading or writing fails (even when using root privileges), see if the the [Special file systems section](#special-file-systems) helps.

## Ejecting the drive

Ejecting a USB drive amounts to unmounting the drive's partitions and then powering off the device.
First **unmount the drive's data partition** with the `umount` command:

```bash
# Unmount the drive's partitions---choose one option.

# Option 1
umount /mnt/usbdrive  # by specifying mount point (preferred)

# Option 2
umount /dev/sdXN      # by specifying the device partition (not preferred)
```

<!-- From `man umount`, specifying the mount directory is preferred, in case the physical device is mounted to multiple directories. -->

You can check the drive is unmounted using `lsblk`---the `MOUNTPOINTS` column for the drive's data partition entry should now be blank.
At this point it's probably safe to remove the drive, but it's best practice to first **power off the drive**;
you can do this by writing directly to the USB drive's device files [(more info on Linux device files)](https://wiki.archlinux.org/title/Device_file).
You'll need to do this with root privileges:

```bash
# Power off the drive itself (e.g. sdb) and not the data partition (e.g. sdb1)

# Option 1: works from a normal user shell using sudo
echo 1 | sudo tee /sys/block/sdX/device/delete

# Option 2: works only from a root shell
echo 1 > /sys/block/sdX/device/delete
```

Note that you can't just `sudo echo 1` as regular user because the sudo privileges aren't transfered through the `>` redirection operation, but you can get around this with `tee`.
For more discussion of the power-off line see [this StackExchange answer](https://unix.stackexchange.com/a/43450) and/or [ArchWiki: USB storage/Device not shutting down after unmounting all partitions](https://wiki.archlinux.org/title/USB_storage_devices#Device_not_shutting_down_after_unmounting_all_partitions).

## Mount automatically

Install the `udisks2` package.

```bash
# Manually
udisksctl mount -b /dev/sdXN
```

By default, udisks2 mounts removable drives under the ACL controlled directory `/run/media/$USER/`.
To change this behavior see [ArchWiki: Udisks/Mount to `/media`](https://wiki.archlinux.org/title/Udisks#Mount_to_/media)

You can automount with [udiskie](https://github.com/coldfix/udiskie).
Install the `udiskie` package.
Basically just autostart `udiskie` in the background when starting X;
`udiskie` will then detect mounted USB drives and mount them using `udisks2` to the default location `/run/media/$USER/`.
See https://github.com/coldfix/udiskie/wiki/Usage for documentation.


### Ejecting with `udisks2`
This package allows you to disconnect power from an e.g. USB drive, which makes for safer ejecting.

Reference:
- `man udisksctl` and `man udisks`

- Install the `udisks2` package

- Mount drive with `umount` as above.

- Eject with
  ```sh
  udisksctl unmount -b /dev/sdb2
  ```
  where the `-b` flag specifies that `/dev/sdb2` refers to a block device.
  Note that a device partition, e.g. `sdb2`, is used.
  Only the device itself, e.g. `sdb`, is used below with `power-off`.

- Power off with 
  ```sh
  udisksctl power-off -b /dev/sdb
  ```
  Again, note that `udisksctl unmount` uses the device's data partition (e.g. `/dev/sdb2`) while `udisksctl power-off` uses the device itself (e.g. `/dev/sdb`).


## Special file systems

If reading or writing fails (even when using root privileges),
your USB drive may be using a file system that requires an additional package before you can read to/write from it.
 Check the USB drive's file system (use e.g. `lsblk -f` and check the `FSTYPE` column), and then install the corresponding package listed in the "Userspace utilities" of the [ArchWiki file system table](https://wiki.archlinux.org/title/file_systems#Types_of_file_systems).
Most commonly you'll run into problems with the NTFS file system and need to install the [`ntfs-3g` package](https://archlinux.org/packages/extra/x86_64/ntfs-3g/).

{% include arch-notes-footer.html %}
