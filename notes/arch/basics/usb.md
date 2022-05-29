---
title: USB drives on Arch Linux
---

# USB drives

{% include arch-notes-header.html %}

**Goal:** Read from and write to external USB drives, including those with the NTFS file system.

**References:**
- [Wiki: USB storage devices](https://wiki.archlinux.org/title/USB_storage_devices)
- [Wiki: NTFS-3G](https://wiki.archlinux.org/title/NTFS-3G)
- [https://wiki.archlinux.org/title/Udisks](https://wiki.archlinux.org/title/Udisks)
- The `man` pages for `lsblk`, `mount`, `umount`, `udisksctl`, and `udisks`

Requirements (depending on the file systems you want to interact with):
- `dosfstools`
- `mtools`
- `ntfs-3g`

These packages allow read/write interaction with the file systems commonly used on USB media.

## Manual everything

Well there's a decent amount going on here.
You should roughly grok what a block device is, and what partitions are.
You should know what a file system is.
You have to mount the USB drive's filesystem to your computer, so the USB drive's files are accessible on your system.

- For future reference, run `lsblk` and remember the output without a USDB connected 

- Physically connect USB drive to computer via a USB port

- Run `lsblk` and identify the drive's block device and data partition:
  ```sh
  $ lsblk
  ```
  It takes a little experience to interpret the output. 
  The USB drive's block device might be `sdb`.
  Identify the data partition based on the known disk size---the data partition should take up the majority of the full disk size.

- Create a mount directory inside `/mnt` to hold the drive's files.
  You can name it whatever you want; perhaps use the manufacturer of the drive:
  ```sh
  sudo mkdir /mnt/seagate
  ```
  You only need to do this step once.

- Mount the drive's data partition to the mount directory
  ```sh
  sudo mount /dev/sdb2 /mount/seagate
  ```
  Optionally use `lsblk` to check that the USB drive is mounted to the just-created mount directory.

- Interact with the files on the USB drive from the `/mnt/seagate` directory, reading and writing as needed.
  You'll need root privileges to write.

- To eject the drive
  ```sh
  umount /mnt/seagate  # by specifying mount point (preferred)
  umount /dev/sdb2     # by specifying device

  # Power off
  echo 1 > /sys/block/DISK_NAME/device/delete
  ```
  From `man umount`, specifying the mount directory is preferred, in case the physical device is mounted to multiple directories.

  For the power off line see [https://unix.stackexchange.com/a/43450](https://unix.stackexchange.com/a/43450)
  and [ArchWiki: USB storage/Device not shutting down after unmounting all partitions](https://wiki.archlinux.org/title/USB_storage_devices#Device_not_shutting_down_after_unmounting_all_partitions)

## Using `udisksctl`

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


### File systems

The `mount` command should detect the USB drive's file system and use the appropriate library if needed.
See e.g. [https://wiki.archlinux.org/title/NTFS-3G](https://wiki.archlinux.org/title/NTFS-3G): the `mount` command should know to use the `ntfs` file system after an installation of `ntfs-3g`.

{% include arch-notes-footer.html %}
