### Redshift
Goal: control (and in general decrease) screen's color temperature.

References:
- [https://wiki.archlinux.org/title/redshift](https://wiki.archlinux.org/title/redshift)
- [GitHub page](https://github.com/jonls/redshift)
- [Project webpage](http://jonls.dk/redshift/)

```sh
pacman -S redshift
```
Config lives in `~/.config/redshift/redshift.conf`
Sample config: [https://github.com/jonls/redshift/blob/master/redshift.conf.sample](https://github.com/jonls/redshift/blob/master/redshift.conf.sample)

Documentation: `man redshift` for options and to some extent the GitHub page.

#### Hello World
To set color temperature to e.g. 3500 K use
```
redshift -PO 3500
```
Something like `3000` is quite reddish; `6500` is considered neutral, but to me is already on the "white" side.
The `-P` options overwrites existing gamma ramps (basically to give you a clean slate) 
and `-O` lets you manually set color temperature without using automatic latitude-based temperature settings.

#### Autostarting
Goal: run `redshift -PO 3500` after starting X.
There are number of ways to autostart `redshift`; I place the following in my `~/.xinitrc` and it seems to do the trick:
```
redshift -O 3500 &
```

