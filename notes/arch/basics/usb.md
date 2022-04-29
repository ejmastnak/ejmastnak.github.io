## External storage

Goal: be able to read from and write to external hard drives, including those with the NTFS file system.

References
- [Wiki: USB storage devices](https://wiki.archlinux.org/title/USB_storage_devices)
- [Wiki: NTFS-3G](https://wiki.archlinux.org/title/NTFS-3G)

Requirements (depending on the file systems you want to interact with):
- `dosfstools`
- `mtools`
- `ntfs-3g`

These packages allow read/write interaction with the file systems commonly used on USB media.

### Basic usage
- Connect drive to computer via USB
- Identify drive and data partition with `fsdisk -l` or `lsblk`.

  Should be something like `/dev/sdb2` (for example)

  Note that the Seagate drive itself was `/dev/sdb`, but the data partition was `/dev/sdb2`, which was obvious based on the `b2` partition's 5 TB size.

- Create a mount directory as root
  ```sh
  mkdir /mnt/seagate
  ```
- Mount the drive's data partition (again as root)
  ```sh
  mount /dev/sdb2 /mount/seagate
  lsblk  # for orientation, to ensure the drive is mounted
  ```
  From [https://wiki.archlinux.org/title/NTFS-3G](https://wiki.archlinux.org/title/NTFS-3G), the `mount` command should know to use the `ntfs` file system after an installation of `ntfs-3g`

- Interact with the files from the `/mnt/seagate` directory

- "Eject" the drive with (as root)
  ```sh
  umount /mnt/seagate  # by specifying mount point (preferred)
  umount /dev/sdb2     # by specifying device
  ```
  From `man umount`, specifying the mount directory is preferred, in case the physical device is mounted to multiple directories.


### Safely ejecting with `udisks2`
This package allows you to disconnect power from an e.g. USB drive, which makes for safer ejecting.

Reference:
- [https://wiki.archlinux.org/title/Udisks](https://wiki.archlinux.org/title/Udisks)
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
