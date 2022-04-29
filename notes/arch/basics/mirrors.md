Goal: good workflow for `pacman` mirrors

The online [Pacman Mirrorlist Generator](https://archlinux.org/mirrorlist/) generates a list of up-to-date mirrors based on your location.

Mirrorlists are stored in `/etc/pacman.d/mirrorlist`.
After editing `/etc/pacman.d/mirrorlist` run `sudo pacman -Syyu` to to updgrade your ssytem with a force refresh all package lists from `yy`.

Source: [ArchWiki: Force `pacman` to refresh the pckage lists](https://wiki.archlinux.org/title/Mirrors#Force_pacman_to_refresh_the_package_lists)

TODO: [`reflector` home page](https://xyne.dev/projects/reflector/)
